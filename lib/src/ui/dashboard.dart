import 'dart:math';

import 'package:commander_ui/tui.dart';
import 'package:vigie/src/ui/components/components.dart';
import 'package:vigie/src/ui/tables.dart';

import '../state.dart';

const memoryLines = 2;
const subtitleLines = 1;

/// Vue d'ensemble : jauges CPU / RAM / disque + résumé des services.
void renderDashboard(RenderContext ctx, VigieState s, Rect area) {
  final o = s.overview;
  if (o == null) {
    ctx.draw(Text(s.t.loading), area);
    return;
  }

  final coreLines = (s.cpu.cores.length / 2).ceil().clamp(1, 8);
  final diskLines = o.disk.length.clamp(1, 6);

  final diskRowHeight =
      max(diskLines, memoryLines) + 1 + subtitleLines + rateLinesHeight;

  final rows = Layout.vertical([
    Constraint.length(coreLines + 2),
    Constraint.length(diskRowHeight + 2),
    Constraint.length(rateLinesHeight + 2),
    const Constraint.fill(1),
  ]).split(area);

  final columnsTop = Layout.horizontal([
    const Constraint.fill(1),
    const Constraint.fill(1),
  ]).split(rows[1]);

  final columnsBottom = Layout.horizontal([
    const Constraint.fill(1),
    const Constraint.fill(1),
  ]).split(rows[2]);

  cpuPanels(ctx, s, rows[0]);
  renderTopProcesses(ctx, s, rows[3]);

  diskPanels(ctx, s, columnsTop[0]);
  memoryPanels(ctx, s, columnsTop[1]);

  networkPanels(ctx, s, columnsBottom[1]);

  final running = s.services.where((x) => x.isRunning).length;
  final failed = s.services.where((x) => x.isFailed).toList();
  final lines = StringBuffer()
    ..writeln(s.t.servicesRunning(running, s.services.length))
    ..writeln(s.t.servicesFailed(failed.length));
  for (final f in failed.take(10)) {
    lines.writeln('  ✗ ${f.name}');
  }
  if (failed.isNotEmpty) {
    lines.writeln('\n${s.t.goToServices}');
  }

  ctx.draw(
    Container(
      border: BorderStyle.single,
      title: s.t.servicesTitle,
      borderColor: failed.isEmpty ? null : const Style(fg: Color.red),
      padding: const EdgeInsets(left: 1, right: 1),
      child: Paragraph(lines.toString()),
    ),
    columnsBottom[0],
  );
}
