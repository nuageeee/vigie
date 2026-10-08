import 'package:commander_ui/tui.dart';

import 'package:vigie/vigie.dart';

Color colorFor(double pct) =>
    pct >= 90 ? Color.red : (pct >= 50 ? Color.yellow : Color.green);

const huitiemes = [' ', '▏', '▎', '▍', '▌', '▋', '▊', '▉'];

String formatKb(int kb) {
  if (kb >= 1024 * 1024) return '${(kb / 1024 / 1024).toStringAsFixed(1)} Go';
  if (kb >= 1024) return '${(kb / 1024).toStringAsFixed(0)} Mo';
  return '$kb Ko';
}

void _box(RenderContext ctx, Rect area, String title) {
  ctx.draw(Container(border: BorderStyle.single, title: title), area);
}

void _drawBars(List<String> names, List<double> pcts, RenderContext ctx, Rect area) {
  final longName = names.fold<int>(
    0,
    (max, names) => names.length > max ? names.length : max,
  );

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
    final barWidth = (w - longName - 7).clamp(1, w);

    final exact = barWidth * pct / 100;
    var full = exact.floor();
    var rest = ((exact - full) * 8).round();
    if (rest == 8) {
      full++;
      rest = 0;
    }

    ctx.draw(Text(names[i], style: const Style(dim: true)), Rect(x, y, longName, 1));
    ctx.draw(
      Text(
        '▉' * full + (rest > 0 ? huitiemes[rest] : ''),
        style: Style(fg: colorFor(pct)),
      ),
      Rect(x + longName + 1, y, barWidth, 1),
    );
    ctx.draw(
      Text('${pct.toStringAsFixed(0)}%'.padLeft(5)),
      Rect(x + longName + barWidth + 1, y, 5, 1),
    );
  }
}

// cpuPanels class
void cpuPanels(RenderContext ctx, VigieState s, Rect area) {
  final cores = s.cpu.cores;
  final names = List.generate(cores.length, ((i) => 'C$i'));

  _box(
    ctx,
    area,
    'CPU · ${cores.length} coeurs · ${s.cpu.total.toStringAsFixed(0)}%',
  );
  
  _drawBars(names, cores, ctx, area);
}

void diskPanels(RenderContext ctx, VigieState s, Rect area) {
  final o = s.overview;
  if (o == null) return;

  final disks = o.disk;
  final totalUsed = disks.fold<double>(
    0,
    (cumul, disks) => cumul + disks.usage,
  );
  final convert = formatKb(totalUsed.toInt());

  _box(ctx, area, 'Disques · ${disks.length} · Total · $convert');

  final names = disks.map((l) => l.name).toList();
  final pct = disks.map((l) => l.Capacity).toList();

  _drawBars(names, pct, ctx, area);
}

void memoryPanels(RenderContext ctx, VigieState s, Rect area) {
  final o = s.overview;
  if (o == null) return;

  final memory = o.memory;
  final totalMemory = memory.fold<double>(
    0,
    (cumul, memory) => cumul + memory.total
  );
  final convertMemFree = formatKb(totalMemory.toInt());
  final totalUsed = memory.fold<double>(
    0,
    (cumul, memory) => cumul + memory.total - memory.free,
  );
  final convert = formatKb(totalUsed.toInt());

  _box(ctx, area, 'Mémoires · Utilisé · $convert · Total · $convertMemFree');

  final names = memory.map((l) => l.name).toList();
  final pct = memory.map((l) => l.memPct).toList();

  _drawBars(names, pct, ctx, area);
}
