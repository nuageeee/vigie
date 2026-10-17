import 'package:commander_ui/tui.dart';
import 'package:vigie/src/system/overview.dart';

import 'dart:math';

import 'package:vigie/src/ui/components/formatters.dart';
import 'package:vigie/src/ui/strings.dart';

import 'package:vigie/vigie.dart';

const rateLinesHeight = 3;
const maxBarWidth = 40;
const percentWidth = 5;

int _longestName(List<String> names) =>
    names.fold(0, (longest, name) => max(longest, name.length));

Color colorFor(double pct) =>
    pct >= 90 ? Color.red : (pct >= 50 ? Color.yellow : Color.green);

const huitiemes = [' ', '▏', '▎', '▍', '▌', '▋', '▊', '▉'];
const huitiemesVertical = ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'];

String formatHistory(List<double> history, int width) {
  final recentValues = history.skip(
    (history.length - width).clamp(0, history.length),
  );
  final maxValue = recentValues.fold<double>(0, (m, value) => max(m, value));
  if (maxValue == 0) return huitiemesVertical[0] * recentValues.length;
  return recentValues.map((value) {
    final index = (huitiemesVertical.length - 1) * value / maxValue;
    return huitiemesVertical[index.floor()];
  }).join();
}

void _box(RenderContext ctx, Rect area, String title) {
  ctx.draw(Container(border: BorderStyle.single, title: title), area);
}

void historyLine(
  RenderContext ctx,
  Rect area,
  String label,
  List<double> values,
  String value, {
  int? labelWidth,
  int? valueWidth,
}) {
  const space = 1;
  final labelCol = labelWidth ?? label.length;
  final valueCol = valueWidth ?? value.length;
  final sparkWidth = area.width - labelCol - space - valueCol - space;

  const dim = Style(dim: true);
  ctx.draw(Text(label, style: dim), Rect(area.x, area.y, labelCol, 1));

  final right = area.x + area.width - value.length;
  ctx.draw(Text(value), Rect(right, area.y, value.length, 1));

  if (sparkWidth <= 0) return;
  final sparkX = area.x + labelCol + space;
  ctx.draw(
    Text(formatHistory(values, sparkWidth)),
    Rect(sparkX, area.y, sparkWidth, 1),
  );
}

void rateLines(
  RenderContext ctx,
  Strings t,
  Rect area,
  RateSampler sampler,
  String labelIn,
  String labelOut,
) {
  if (area.height < rateLinesHeight) return;

  final yIn = area.y;
  final yOut = area.y + rateLinesHeight - 1;

  final valueIn = formatOc(sampler.rateIn.toInt(), t);
  final valueOut = formatOc(sampler.rateOut.toInt(), t);

  final labelWidth = max(labelIn.length, labelOut.length);
  final valueWidth = max(valueIn.length, valueOut.length);

  historyLine(
    ctx,
    Rect(area.x, yIn, area.width, 1),
    labelIn,
    sampler.historyIn.values,
    valueIn,
    labelWidth: labelWidth,
    valueWidth: valueWidth,
  );
  historyLine(
    ctx,
    Rect(area.x, yOut, area.width, 1),
    labelOut,
    sampler.historyOut.values,
    valueIn,
    labelWidth: labelWidth,
    valueWidth: valueWidth,
  );
}

void _drawBars(
  List<String> names,
  List<double> pcts,
  RenderContext ctx,
  Rect area,
) {
  final longName = _longestName(names);

  final inner = Rect(area.x + 2, area.y + 1, area.width - 4, area.height - 2);
  if (inner.height <= 0 || inner.width <= 0) return;

  final perColumn = inner.height;
  final columns = (names.length / perColumn).ceil();
  final colWidth = inner.width ~/ columns;

  for (var i = 0; i < names.length; i++) {
    final x = inner.x + (i ~/ perColumn) * colWidth;
    final y = inner.y + (i % perColumn);
    final w = colWidth - 1;
    final pct = pcts[i];
    final barWidth = (w - longName - 7).clamp(1, maxBarWidth);

    final exact = barWidth * pct / 100;
    var full = exact.floor();
    var rest = ((exact - full) * 8).round();
    if (rest == 8) {
      full++;
      rest = 0;
    }

    final partial = rest > 0 ? 1 : 0;

    ctx.draw(
      Text(names[i], style: const Style(dim: true)),
      Rect(x, y, longName, 1),
    );

    ctx.draw(
      Text(
        '█' * full + (rest > 0 ? huitiemes[rest] : ''),
        style: Style(fg: colorFor(pct)),
      ),
      Rect(x + longName + 1, y, barWidth, 1),
    );

    final track = barWidth - full - partial;

    ctx.draw(
      Text('░' * track, style: const Style(dim: true)),
      Rect(x + longName + 1 + full + partial, y, track, 1),
    );
    ctx.draw(
      Text('${pct.toStringAsFixed(0)}%'.padLeft(percentWidth)),
      Rect(x + longName + barWidth + 1, y, percentWidth, 1),
    );
  }
}

// cpuPanels class
void cpuPanels(RenderContext ctx, VigieState s, Rect area) {
  final cores = s.cpu.cores;
  final names = List.generate(cores.length, ((i) => 'C$i'));

  _box(ctx, area, s.t.cpuTitle(cores.length, s.cpu.total.toStringAsFixed(0)));

  final columnsWidth = _longestName(names) + maxBarWidth + 8;
  final barsWidth = 2 * columnsWidth + 4;

  final barsArea = Rect(
    area.x,
    area.y,
    min(area.width, barsWidth),
    area.height,
  );

  _drawBars(names, cores, ctx, barsArea);

  final historyX = barsArea.x + barsArea.width;
  final historyWidth = (area.right - 2) - historyX;
  if (historyWidth < 20) return;

  historyLine(
    ctx,
    Rect(historyX, area.y + 1, historyWidth, 1),
    'Total',
    s.cpu.historyTotal.values,
    '${s.cpu.total.toStringAsFixed(0)}%',
  );
}

void diskPanels(RenderContext ctx, VigieState s, Rect area) {
  final o = s.overview;
  if (o == null) return;

  final disks = o.disk;
  final names = disks.map((l) => l.name).toList();
  final pct = disks.map((l) => l.capacity).toList();

  // une ligne de barre : nom + espace + barre + pourcentage
  final barRowWidth = _longestName(names) + 1 + maxBarWidth + percentWidth;

  final rateArea = Rect(
    area.x + 2,
    area.y + disks.length + 3,
    min(area.width - 4, barRowWidth),
    rateLinesHeight,
  );

  final totalUsed = disks.fold<double>(
    0,
    (cumul, disks) => cumul + disks.usage,
  );
  final convert = formatKb(totalUsed.toInt(), s.t);

  _box(ctx, area, s.t.disksTitle(disks.length, convert));

  _drawBars(names, pct, ctx, area);

  ctx.draw(
    Text(s.t.diskActivity, style: const Style(dim: true)),
    Rect(rateArea.x, rateArea.y - 1, area.width, 1),
  );

  rateLines(ctx, s.t, rateArea, s.diskIo, s.t.diskRead, s.t.diskWrite);
}

void memoryPanels(RenderContext ctx, VigieState s, Rect area) {
  final o = s.overview;
  if (o == null) return;

  final memory = o.memory;
  final totalMemory = memory.fold<double>(
    0,
    (cumul, memory) => cumul + memory.total,
  );
  final convertMemFree = formatKb(totalMemory.toInt(), s.t);
  final totalUsed = memory.fold<double>(
    0,
    (cumul, memory) => cumul + memory.total - memory.free,
  );
  final convert = formatKb(totalUsed.toInt(), s.t);

  _box(ctx, area, s.t.memoryTitle(convert, convertMemFree));

  final names = memory.map((l) => l.name).toList();
  final pct = memory.map((l) => l.memPct).toList();

  _drawBars(names, pct, ctx, area);
}

void networkPanels(RenderContext ctx, VigieState s, Rect area) {
  _box(ctx, area, s.t.network);

  final inner = Rect(area.x + 2, area.y + 1, area.width - 4, area.height - 2);

  rateLines(ctx, s.t, inner, s.net, '↓', '↑');
}

void topProcessesPanels(RenderContext ctx, VigieState s, Rect area) {
  _box(ctx, area, s.t.topProcesses);
}
