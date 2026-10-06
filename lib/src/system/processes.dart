import 'dart:io';

import 'shell.dart';

class Proc {
  final int pid;
  final String user;
  final double cpu;
  final double mem;
  final int rssKb;
  final String command;

  const Proc(this.pid, this.user, this.cpu, this.mem, this.rssKb, this.command);
}

class ProcSampler {
  final _cpus = Platform.numberOfProcessors;
  final _lastTicks = <int, int>{};
  int _lastTotal = 0;

  Future<List<Proc>> sample() async {
    final total = _totalTicks();
    final dTotal = total - _lastTotal;
    _lastTotal = total;

    final users = _uidToName();
    final memTotalKb = _memTotalKb();
    final seen = <int, int>{};
    final list = <Proc>[];

    for (final entry in Directory('/proc').listSync()) {
      final pid = int.tryParse(entry.path.split('/').last);
      if (pid == null) continue;

      final stat = readFile('/proc/$pid/stat');
      if (stat.isEmpty) continue;

      final close = stat.lastIndexOf(')');
      final f = stat.substring(close + 2).split(' ');

      final ticks = (int.tryParse(f[11]) ?? 0) + (int.tryParse(f[12]) ?? 0);
      seen[pid] = ticks;

      final prev = _lastTicks[pid];
      final cpu = (prev == null || dTotal < 0) ? 0.0 : (ticks - prev) * 100.0 * _cpus / dTotal;

      final status = readFile('/proc/$pid/status');
      if (_field(status, 'VmRSS') == null) continue;
      final name = _field(status, 'Name');
      final uid = (_field(status, 'Uid') ?? '').split(RegExp(r'\s+')).first;
      final rssKb = int.tryParse(
        (_field(status, 'VmRSS') ?? '0').split(' ').first
      ) ?? 0;

      list.add(Proc(
        pid,
        users[uid] ?? uid,
        cpu,
        memTotalKb == 0 ? 0 : rssKb * 100 / memTotalKb,
        rssKb,
        name!,
      ));
    }

    _lastTicks..clear()..addAll(seen);

    list.sort((a, b) => b.cpu.compareTo(a.cpu));
    return list.take(300).toList();
  }
}

  int _totalTicks() {
    final first = readFile('/proc/stat').split('\n').first;
    return first
        .split(RegExp(r'\s+'))
        .skip(1)
        .map(int.tryParse)
        .whereType<int>()
        .fold(0, (a, b) => a + b);
  }

  int _memTotalKb() {
    final m = RegExp(r'^MemTotal:\s+(\d+)', multiLine: true)
        .firstMatch(readFile('/proc/meminfo'));
    return int.tryParse(m?.group(1) ?? '') ?? 0;
  }

  Map<String, String> _uidToName() {
    final map = <String, String>{};
    for (final line in readFile('/etc/passwd').split('\n')) {
      final p = line.split(':');
      if (p.length > 2) map[p[2]] = p[0];
    }
    return map;
  }

  String? _field(String status, String key) {
    final m = RegExp('^$key:\\s*(.*)\$', multiLine: true).firstMatch(status);
    return m?.group(1)?.trim();
  }

Future<CmdResult> killProcess(Proc p, {bool force = false}) => run(
      'kill',
      [force ? '-KILL' : '-TERM', '${p.pid}'],
      success: force
          ? '${p.command} (${p.pid}) tué'
          : 'Signal d\'arrêt envoyé à ${p.command} (${p.pid})',
    );

String formatKb(int kb) {
  if (kb >= 1024 * 1024) return '${(kb / 1024 / 1024).toStringAsFixed(1)} Go';
  if (kb >= 1024) return '${(kb / 1024).toStringAsFixed(0)} Mo';
  return '$kb Ko';
}
