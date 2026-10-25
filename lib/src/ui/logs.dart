import 'dart:math';

import 'package:commander_ui/tui.dart';
import 'package:vigie/src/system/journal.dart';
import 'package:vigie/src/ui/components/formatters.dart';
import 'package:vigie/vigie.dart';

Style _logStyle(Gravity g) => switch (g) {
  Gravity.error => const Style(fg: Color.red),
  Gravity.warning => const Style(fg: Color.yellow),
  Gravity.normal => const Style(),
  Gravity.debug => const Style(dim: true)
};

void renderLogs(RenderContext ctx, VigieState s, Rect area) {
  final view = s.logs;
  if (view == null) return;
  final inner = Rect(area.x + 2, area.y + 1, area.width - 4, area.height - 2);

  ctx.draw(
    Container(border: BorderStyle.single, title: view.source.title),
    area,
  );

  if (view.loading) {
     ctx.draw(Text(s.t.logsLoading), inner);
    return;
  }
  if (view.entries.isEmpty) {
    ctx.draw(Text(s.t.logsEmpty), inner);
    return;
  }

  final maxScroll = max(0, view.entries.length - inner.height);
  view.scroll = view.scroll.clamp(0, maxScroll);

  for (var i = 0; i < inner.height; i++) {
    final index = view.scroll + i;
    if (index >= view.entries.length) break;
    final entry = view.entries[index];
    ctx.draw(Text(formatLogLine(entry), style: _logStyle(levelOf(entry.priority))), Rect(inner.x, inner.y + i, inner.width, 1));
  }
}
