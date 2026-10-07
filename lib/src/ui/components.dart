import 'package:commander_ui/tui.dart';
import 'package:vigie/src/system/overview.dart';
import 'package:vigie/vigie.dart';

Color colorFor(double pct) =>
    pct >= 90 ? Color.red : (pct >= 50 ? Color.yellow : Color.green);

const huitiemes = [' ', '▏', '▎', '▍', '▌', '▋', '▊', '▉'];

void _box(RenderContext ctx, Rect area, String title) {
  ctx.draw(Container(border: BorderStyle.single, title: title), area);
}

// cpuPanels class
void cpuPanels(RenderContext ctx, VigieState s, Rect area) {
  final cores = s.cpu.cores;

_box(
    ctx,
    area,
    'CPU · ${cores.length} coeurs · ${s.cpu.total.toStringAsFixed(0)}%',
  );

  // Inside border
  final inner = Rect(area.x + 2, area.y + 1, area.width - 4, area.height - 2);
  if (inner.height <= 0 || inner.width <= 0) return;

  final perColumn = inner.height;
  final columns = (cores.length / perColumn).ceil();
  final colWidth = inner.width ~/ columns;

  for (var i = 0; i < cores.length; i++) {
    final x = inner.x + (i ~/ perColumn) * colWidth;
    final y = inner.y + (i % perColumn);
    final w = colWidth - 1;
    final pct = cores[i];
    final barWidth = (w - 10).clamp(1, w);

    final exact = barWidth * pct / 100;
    var full = exact.floor();
    var rest = ((exact - full) * 8).round();
    if (rest == 8) {
      full++;
      rest = 0;
    }

    ctx.draw(Text('C$i', style: const Style(dim: true)), Rect(x, y, 4, 1));
    ctx.draw(
      Text(
        '▉' * full + (rest > 0 ? huitiemes[rest] : ''),
        style: Style(fg: colorFor(pct)),
      ),
      Rect(x + 4, y, barWidth, 1),
    );
    ctx.draw(
      Text('${pct.toStringAsFixed(0)}%'.padLeft(5)),
      Rect(x + 4 + barWidth + 1, y, 5, 1),
    );
  }
}

void diskPanels(RenderContext ctx, VigieState s, Rect area) {
  final o = s.overview;
  if (o == null) return;

  final disks = o.disk;

  _box(
    ctx,
    area,
    'Disques · ${disks.length} · Total · ${disks}',
  );

  final inner = Rect(area.x + 2, area.y + 1, area.width - 4, area.height -2);
  if (inner.height <= 0 || inner.width <= 0) return;

  final perColumn = inner.height;
  final columns = (disks.length / perColumn).ceil();
  final colWidth = inner.width ~/ columns;

  for (var i = 0; i < disks.length; i++) {
    final x = inner.x + (i ~/ perColumn) * colWidth;
    final y = inner.y + (i % perColumn);
    final w = colWidth - 1;
    final used = disks[i].usage;
    final barWidth = (w - 10).clamp(1, w);

    final exact = barWidth * disks[i].Capacity / 100;
    var full = exact.floor();
    var rest = ((exact - full) * 8).round();
    if (rest == 8) {
      full++;
      rest=0;
    }

    ctx.draw(Text(disks[i].name, style: const Style(dim: true)), Rect(x, y, 4 + 1, 1));
        ctx.draw(
      Text(
        '▉' * full + (rest > 0 ? huitiemes[rest] : ''),
        style: Style(fg: colorFor(exact)),
      ),
      Rect(x + 4, y, barWidth, 1),
    );
  }
}