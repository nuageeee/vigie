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
  const line = Style(dim: true);
  const logo = ' 👁 Vigie ';

  final labels = [
    for (var i = 0; i < Section.values.length; i++)
      ' ${i + 1} ${Section.values[i].label}',
  ];
  final tabsWidth =
      labels.fold<int>(0, (w, l) => w + l.length) + labels.length - 1;

  ctx.draw(const Text('|', style: line), Rect(area.x, area.y, 1, 1));
  ctx.draw(const Text('|', style: line), Rect(area.right - 1, area.y, 1, 1));

  final logoX = area.x + 1;
  ctx.draw(
    const Text(logo, style: Style(bold: true, fg: Color.cyan)),
    Rect(logoX, area.y, logo.length + 1, 1),
  );
  final logoEnd = logoX + logo.length + 1;

  var x = area.right - 2 - tabsWidth;

  final fill = x - 1 - logoEnd;
  if (fill > 0) {
    ctx.draw(Text('─' * fill, style: line), Rect(logoEnd, area.y, fill, 1));
  }

    for (var i = 0; i < labels.length; i++) {
    final label = labels[i];
    final active = Section.values[i] == s.section;
    final rect = Rect(x, area.y, label.length, 1);
    if (x >= logoEnd) {
      // On ne dessine pas par-dessus le logo si le terminal est trop étroit.
      ctx.draw(
        Text(label,
            style: active
                ? const Style(reverse: true, bold: true)
                : const Style(dim: true)),
        rect,
      );
    }
    x += label.length + 1;
  }
}

void _systemBar(RenderContext ctx, VigieState s, Rect area) {
  ctx.draw(Container(border: BorderStyle.single, title: "Système"), area);
  final o = s.overview;
  if (o == null) return;

  final info = [
    ('Hôte', o.hostname),
    ('OS', o.os),
    ('Kernel', o.kernel),
    ('Uptime', formatUptime(o.uptime)),
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
