import 'dart:io' show pid;

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

/// Les processus triés par consommation CPU (les 300 premiers).
Future<List<Proc>> loadProcesses() async {
  final out = await capture('ps', [
    '-eo',
    'pid=,ppid=,user=,pcpu=,pmem=,rss=,comm=',
    '--sort=-pcpu',
  ]);
  final list = <Proc>[];
  for (final line in out.split('\n')) {
    final p = splitColumns(line, 7);
    if (p.length < 7) continue;
    // On masque le `ps` que Vigie vient de lancer lui-même (son parent = Vigie).
    if (p[1] == '$pid') continue;
    list.add(Proc(
      int.tryParse(p[0]) ?? 0,
      p[2],
      double.tryParse(p[3]) ?? 0,
      double.tryParse(p[4]) ?? 0,
      int.tryParse(p[5]) ?? 0,
      p[6],
    ));
    if (list.length >= 300) break;
  }
  return list;
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
