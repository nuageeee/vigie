import 'package:commander_ui/tui.dart';
import 'package:vigie/src/system/overview.dart';
import 'package:vigie/src/ui/components.dart';

import '../state.dart';
import '../system/processes.dart';

/// Vue d'ensemble : jauges CPU / RAM / disque + résumé des services.
void renderDashboard(RenderContext ctx, VigieState s, Rect area) {
  final o = s.overview;
  if (o == null) {
    ctx.draw(const Text(' Chargement...'), area);
    return;
  }

  void gauge(String title, double pct, String label, Rect r) => ctx.draw(
    Container(
      border: BorderStyle.single,
      title: ' $title ',
      padding: const EdgeInsets(left: 1, right: 1),
      child: Gauge(
        value: pct,
        label: label,
        style: Style(bg: colorFor(pct), fg: Color.black),
      ),
    ),
    r,
  );

  final coreLines = s.cpu.cores.length.clamp(1, 8);

  final rows = Layout.vertical([
    Constraint.length(coreLines + 2),
    const Constraint.length(3),
    const Constraint.length(3),
    const Constraint.fill(1),
  ]).split(area);

  final diskLines = o.disk.length.clamp(1, 0);

  final columns = Layout.horizontal([
    Constraint.length(diskLines + 2),
    const Constraint.fill(1),
    const Constraint.fill(1),
  ]).split(rows[1]);

  cpuPanels(ctx, s, rows[0]);
  diskPanels(ctx, s, columns[0]);

  gauge(
    'Mémoire',
    o.memPercent,
    '${formatKb(o.memUsedKb)} / ${formatKb(o.memTotalKb)}',
    rows[2],
  );

/*   gauge(
    'Disque /',
    o.diskPercent,
    '${formatKb(o.diskUsedKb)} / ${formatKb(o.diskTotalKb)}',
    rows[2],
  );
 */
  final running = s.services.where((x) => x.isRunning).length;
  final failed = s.services.where((x) => x.isFailed).toList();
  final lines = StringBuffer()
    ..writeln('Services actifs : $running / ${s.services.length}')
    ..writeln('Services en échec : ${failed.length}');
  for (final f in failed.take(10)) {
    lines.writeln('  ✗ ${f.name}');
  }
  if (failed.isNotEmpty) {
    lines.writeln('\n→ touche 4 pour aller les gérer');
  }

  ctx.draw(
    Container(
      border: BorderStyle.single,
      title: ' Services ',
      borderColor: failed.isEmpty ? null : const Style(fg: Color.red),
      padding: const EdgeInsets(left: 1, right: 1),
      child: Paragraph(lines.toString()),
    ),
    rows[3],
  );
}
