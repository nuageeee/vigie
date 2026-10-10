import 'package:commander_ui/tui.dart';
import 'package:vigie/src/state.dart';
import 'package:vigie/src/ui/components/formators.dart';
import 'package:vigie/src/ui/dashboard.dart';
import 'package:vigie/src/ui/prompt.dart';
import 'package:vigie/src/ui/tables.dart';

typedef General = (String key, String label, KeyEvent ev, Color color);

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
      ' ${i + 1} ${s.t.sectionLabel(Section.values[i])} ',
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
  ctx.draw(Container(border: BorderStyle.single, title: s.t.system), area);
  final o = s.overview;
  if (o == null) return;

  final info = [
    (s.t.host, o.hostname),
    (s.t.os, o.os),
    (s.t.kernel, o.kernel),
    (s.t.uptime, formatUptime(o.uptime, s.t)),
    (s.t.ip, o.ip),
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

int _buttonWidth(int keyLength, int labelLength, {bool compact = false}) =>
    compact
    ? keyLength + 2
    : keyLength + labelLength + 3; // espace + key + espace + label + espace
int _generalsWidth(List<General> general, {bool compact = false}) =>
    general.fold<int>(
      0,
      (w, b) =>
          w + _buttonWidth(b.$1.length, b.$2.length, compact: compact) + 1,
    ) -
    1;

int _buttons(
  RenderContext ctx,
  VigieState s,
  int x,
  int y,
  int maxX,
  List<(String key, String label, KeyEvent ev, Color color)> buttons, {
  bool compact = false,
}) {
  for (final (key, label, ev, color) in buttons) {
    final width = _buttonWidth(key.length, label.length, compact: compact);
    if (x + width > maxX) break;
    ctx.draw(
      Text(
        compact ? ' $key ' : ' $key',
        style: Style(fg: Color.black, bg: color, bold: true),
      ),
      compact ? Rect(x, y, key.length + 2, 1) : Rect(x, y, key.length + 1, 1),
    );
    if (!compact) {
      ctx.draw(
        Text(' $label ', style: const Style(reverse: true)),
        Rect(x + key.length + 1, y, label.length + 2, 1),
      );
    }
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
      (s.t.yesKey, s.t.yes, _c(s.t.yesKey), Color.green),
      (s.t.noKey, s.t.no, _c(s.t.noKey), Color.red),
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
    ctx.draw(Text(s.t.promptHelp, style: const Style(dim: true)), area);
    return;
  }

  final general = [
    ('!', s.t.btnTerminal, _c('!'), Color.magenta),
    ('F5', s.t.btnRefresh, const KeyEvent(key: NamedKey.f5), Color.blue),
    ('q', s.t.btnQuit, _c('q'), Color.white),
  ];
  final generalWidth = _generalsWidth(general);
  final gx = area.right - generalWidth;

  final actions = switch (s.section) {
    Section.table => <(String, String, KeyEvent, Color)>[],
    Section.users => [
      ('a', s.t.btnAdd, _c('a'), Color.green),
      ('p', s.t.btnPassword, _c('p'), Color.cyan),
      ('v', s.t.btnLock, _c('v'), Color.yellow),
      ('g', s.t.btnAdmin, _c('g'), Color.yellow),
      ('D', s.t.btnDelete, _c('D'), Color.red),
    ],
    Section.process => [
      ('t', s.t.btnTerm, _c('t'), Color.yellow),
      ('K', s.t.btnKill, _c('K'), Color.red),
    ],
    Section.services => [
      ('s', s.t.btnStart, _c('s'), Color.green),
      ('x', s.t.btnStop, _c('x'), Color.red),
      ('r', s.t.btnRestart, _c('r'), Color.yellow),
      ('e', s.t.btnEnable, _c('e'), Color.cyan),
      ('d', s.t.btnDisable, _c('d'), Color.cyan),
    ],
  };

  final freeSpace = (gx - 1) - (area.x + 1);
  final compact = (_generalsWidth(actions) > freeSpace);

  _buttons(ctx, s, gx, area.y, area.right, general);
  _buttons(ctx, s, area.x + 1, area.y, gx - 1, actions, compact: compact);
}
