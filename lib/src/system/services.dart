import 'dart:io';

import 'shell.dart';

class Service {
  final String name;
  final String active; // active, inactive, failed...
  final String sub; // running, exited, dead...
  final String enabled; // enabled, disabled, static, masked...
  final String description;

  const Service(
    this.name,
    this.active,
    this.sub,
    this.enabled,
    this.description,
  );

  bool get isRunning => active == 'active';
  bool get isFailed => active == 'failed';
}

final _sshProcess = RegExp(r'^(sshd|sshd-session)$');

bool hasSshAncestor(List<String> ancestors) =>
    ancestors.any((name) => _sshProcess.hasMatch(name));

int? parsePpid(String stat) {
  final end = stat.lastIndexOf(')');
  if (end == -1) return null;

  final after = stat.substring(end + 1);
  final pieces = after.trim().split(' ');
  if (pieces.length < 2) return null;

  return int.tryParse(pieces[1]);
}

List<String> readAncestorNames() {
  var current = pid;
  final parents = <String>[];
  for (var i = 0; i < 64; i++) {
    try {
      final name = readFile('/proc/$current/comm').trim();
      var stat = parsePpid(readFile('/proc/$current/stat'));
      parents.add(name);
      if (stat == null || stat <= 1) break;
      current = stat;
    } catch (_) {
      break;
    }
  }
  return parents;
}

enum SshRefusalReason { sshLockout }

final _sshService = RegExp(r'^(ssh|sshd)(\.service|\.socket)?$');
SshRefusalReason? checkServiceTarget(Map<String, String> env, String service, List<String> ancestors) {
  final inSsh = env['SSH_CONNECTTION'] != null || hasSshAncestor(ancestors);
  final targetsSsh = _sshService.hasMatch(service);
  if (inSsh && targetsSsh) return SshRefusalReason.sshLockout;
  return null;
}

/// Liste les services systemd chargés, avec leur état au démarrage.
Future<List<Service>> loadServices() async {
  final units = await capture('systemctl', [
    'list-units',
    '--type=service',
    '--all',
    '--no-pager',
    '--plain',
    '--no-legend',
  ]);
  final files = await capture('systemctl', [
    'list-unit-files',
    '--type=service',
    '--no-pager',
    '--no-legend',
  ]);

  final enabledByName = <String, String>{};
  for (final line in files.split('\n')) {
    final p = splitColumns(line, 3);
    if (p.length >= 2) enabledByName[p[0]] = p[1];
  }

  final list = <Service>[];
  for (final line in units.split('\n')) {
    // UNIT LOAD ACTIVE SUB DESCRIPTION
    final p = splitColumns(line, 5);
    if (p.length < 4 || p[1] != 'loaded') continue;
    list.add(
      Service(
        p[0],
        p[2],
        p[3],
        enabledByName[p[0]] ?? '-',
        p.length > 4 ? p[4] : '',
      ),
    );
  }
  // Les services en échec d'abord, puis ceux qui tournent, puis le reste.
  int rank(Service s) => s.isFailed ? 0 : (s.isRunning ? 1 : 2);
  list.sort((a, b) {
    final r = rank(a) - rank(b);
    return r != 0 ? r : a.name.compareTo(b.name);
  });
  return list;
}

Future<CmdResult> serviceAction(String verb, Service s) =>
    run('systemctl', [verb, s.name]);
