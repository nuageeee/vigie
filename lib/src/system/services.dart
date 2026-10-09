import 'shell.dart';

class Service {
  final String name;
  final String active; // active, inactive, failed...
  final String sub; // running, exited, dead...
  final String enabled; // enabled, disabled, static, masked...
  final String description;

  const Service(this.name, this.active, this.sub, this.enabled, this.description);

  bool get isRunning => active == 'active';
  bool get isFailed => active == 'failed';
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
    list.add(Service(
      p[0],
      p[2],
      p[3],
      enabledByName[p[0]] ?? '-',
      p.length > 4 ? p[4] : '',
    ));
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
