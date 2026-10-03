import 'dart:io';

import 'package:commander_ui/tui.dart';
import 'package:vigie/src/state.dart';
import 'package:vigie/src/system/overview.dart';

void render(RenderContext ctx, VigieState s) {
  final rows = Layout.vertical([
    const Constraint.length(1),
    const Constraint.fill(1),
    const Constraint.length(1),
    const Constraint.length(1),
  ]).split(ctx.area);

  _topBar(ctx, s, rows[0]);

  final body = Layout.horizontal([
    const Constraint.length(24),
    const Constraint.fill(1),
  ]).split(rows[1]);

  _systemBar(ctx, s, body[0]);
}

void _topBar(RenderContext ctx, VigieState s, Rect area) {
  ctx.draw(Container(border: BorderStyle.single, title: 'Vigie'), area);

}

void _systemBar(RenderContext  ctx, VigieState s,Rect area) {
  ctx.draw(Container(border: BorderStyle.single, title: "Système"), area);
  final o = s.overview;
  if (o == null) return;

  final info = [
    ('Hôte', o.hostname),
    ('OS', o.os),
    ('Kernel', o.kernel),
    ('Uptime', formatUptime(o.uptime))
  ];

  var y = area.y + 1;
  final x = area.x + 2;
  final w = area.width - 4;
  for (final (label, value) in info) {
    if (y + 1 >= area.bottom - 1) break;
    ctx.draw(Text(label, style: const Style(dim: true)), Rect(x, y, w, 1));
    ctx.draw(Text(value, style: const Style(bold: true)), Rect(x, y + 1, w, 1));
    y += 3;
   }
}