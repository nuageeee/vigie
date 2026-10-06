import 'package:commander_ui/tui.dart';
import 'package:vigie/vigie.dart';

Color colorFor(double pct) =>
    pct >= 90 ? Color.red : (pct >= 50 ? Color.yellow : Color.green);


// cpuPanels class
void cpuPanels(RenderContext ctx, VigieState s, Rect area) {
  final cores = s.cpu.cores;
  const huitiemes = [' ', '▏', '▎', '▍', '▌', '▋', '▊', '▉'];

  ctx.draw(
    Container(
      border: BorderStyle.single,
      title:
          'CPU · ${cores.length} coeurs · ${s.cpu.total.toStringAsFixed(0)}%',
    ),
    area,
  );
  if (cores.isEmpty) return;

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
  
}