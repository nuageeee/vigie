import 'package:commander_ui/tui.dart';
import 'package:vigie/src/ui/components/components.dart';

import '../state.dart';

/// Vue d'ensemble : jauges CPU / RAM / disque + résumé des services.
void renderDashboard(RenderContext ctx, VigieState s, Rect area) {
  final o = s.overview;
  if (o == null) {
    ctx.draw(const Text(' Chargement...'), area);
    return;
  }

  final coreLines = s.cpu.cores.length.clamp(1, 8);
  final diskLines = o.disk.length.clamp(1, 6);

  final rows = Layout.vertical([
    Constraint.length(coreLines + 2),
    Constraint.length(diskLines + 2),
    const Constraint.fill(1),
  ]).split(area);

  final columnsTop = Layout.horizontal([
    const Constraint.fill(1),
    const Constraint.fill(1)
  ]).split(rows[1]);

  final columnsBottom = Layout.horizontal([
    const Constraint.fill(1),
    const Constraint.fill(1),
  ]).split(rows[2]);

  cpuPanels(ctx, s, rows[0]);

  diskPanels(ctx, s, columnsTop[0]);
  memoryPanels(ctx, s, columnsTop[1]);

  networkPanels(ctx, s, columnsBottom[1]);

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
    columnsBottom[0],
  );
}
