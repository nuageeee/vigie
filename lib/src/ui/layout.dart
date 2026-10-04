import 'package:commander_ui/tui.dart';
import 'package:vigie/src/state.dart';
import 'package:vigie/src/system/overview.dart';
import 'package:vigie/src/ui/dashboard.dart';
import 'package:vigie/src/ui/prompt.dart';
import 'package:vigie/src/ui/tables.dart';

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

  final prompt = s.prompt;
  if (prompt != null) {
    renderPrompt(ctx, prompt, body[1]);
  } else {
    switch (s.section) {
      case Section.table:
        renderDashboard(ctx, s, body[1]);
      case Section.users:
        renderUsers(ctx, s, body[1]);
      case Section.process:
        renderProcesses(ctx, s, body[1]);
      case Section.services:
        renderServices(ctx, s, body[1]);
    }
  }

  _statusBar(ctx, s, rows[2]);
  _actionBar(ctx, s, Rect(rows[3].x, rows[3].y, rows[3].width - 1, 1));
}

void _topBar(RenderContext ctx, VigieState s, Rect area) {
  const line = Style(dim: true);
  const logo = ' ◉ Vigie ';

  final labels = [
    for (var i = 0; i < Section.values.length; i++)
      ' ${i + 1} ${Section.values[i].label} ',
  ];
  final tabsWidth =
      labels.fold<int>(0, (w, l) => w + l.length) + labels.length - 1;

  ctx.draw(const Text('|', style: line), Rect(area.x, area.y, 1, 1));
  ctx.draw(const Text('|', style: line), Rect(area.right - 1, area.y, 1, 1));

  final logoX = area.x + 1;
  ctx.draw(
    const Text(logo, style: Style(bold: true, fg: Color.cyan)),
    Rect(logoX, area.y, logo.length, 1),
  );
  final logoEnd = logoX + logo.length;

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
        Text(
          label,
          style: active
              ? const Style(reverse: true, bold: true)
              : const Style(dim: true),
        ),
        rect,
      );
    }

    s.clickZones.add(
      ClickZone(
        Rect(rect.x, rect.y, rect.width, 2),
        key: KeyEvent(char: '${i + 1}'),
      ),
    );

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

int _buttons(
  RenderContext ctx,
  VigieState s,
  int x,
  int y,
  int maxX,
  List<(String key, String label, KeyEvent ev, Color color)> buttons,
) {
  for (final (key, label, ev, color) in buttons) {
    final width =
        key.length + label.length + 3; // espace + key + espace + label + espace
    if (x + width > maxX) break;
    ctx.draw(
      Text(
        ' $key',
        style: Style(fg: Color.black, bg: color, bold: true),
      ),
      Rect(x, y, key.length + 1, 1),
    );
    ctx.draw(
      Text(' $label ', style: const Style(reverse: true)),
      Rect(x + key.length + 1, y, label.length + 2, 1),
    );
    s.clickZones.add(ClickZone(Rect(x, y, width, 1), key: ev));
    x += width + 1;
  }
  return x;
}

KeyEvent _c(String c) => KeyEvent(char: c);

void _statusBar(RenderContext ctx, VigieState s, Rect area) {
  final pending = s.pending;
  if (pending != null) {
    final q = ' ⚠  ${pending.question} ';
    ctx.draw(
      Text(q, style: const Style(fg: Color.yellow, bold: true)),
      Rect(area.x, area.y, q.length + 1, 1),
    );
    _buttons(ctx, s, area.x + q.length + 2, area.y, area.right, [
      ('o', 'Oui', _c('o'), Color.green),
      ('n', 'Non', _c('n'), Color.red),
    ]);
    return;
  }
  ctx.draw(
    Text(
      ' ${s.statusError ? '✗' : '✓'} ${s.status}',
      style: Style(fg: s.statusError ? Color.red : Color.green),
    ),
    area,
  );
}

void _actionBar(RenderContext ctx, VigieState s, Rect area) {
  if (s.prompt != null) {
    ctx.draw(
      const Text(' Entrée valider · Échap annuler', style: Style(dim: true)),
      area,
    );
    return;
  }

  final actions = switch (s.section) {
    Section.table => <(String, String, KeyEvent, Color)>[],
    Section.users => [
      ('a', 'ajouter', _c('a'), Color.green),
      ('p', 'mot de passe', _c('p'), Color.cyan),
      ('v', 'verrouiller', _c('v'), Color.yellow),
      ('g', 'admin', _c('g'), Color.yellow),
      ('D', 'supprimer', _c('D'), Color.red),
    ],
    Section.process => [
      ('t', 'arrêter', _c('t'), Color.yellow),
      ('K', 'tuer', _c('K'), Color.red),
    ],
    Section.services => [
      ('s', 'démarrer', _c('s'), Color.green),
      ('x', 'arrêter', _c('x'), Color.red),
      ('r', 'redémarrer', _c('r'), Color.yellow),
      ('e', 'activer boot', _c('e'), Color.cyan),
      ('d', 'désactiver boot', _c('d'), Color.cyan),
    ],
  };

  var x = _buttons(ctx, s, area.x + 1, area.y, area.right, actions);

  final general = [
    ('F5', 'rafraîchir', const KeyEvent(key: NamedKey.f5), Color.blue),
    ('q', 'quitter', _c('q'), Color.white),
  ];
  final generalWidth =
      general.fold<int>(0, (w, b) => w + b.$1.length + b.$2.length + 3 + 1) - 1;
  final gx = area.right - generalWidth;
  if (gx > x) {
    _buttons(ctx, s, gx, area.y, area.right, general);
  }
}
