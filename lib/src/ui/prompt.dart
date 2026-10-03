import 'package:commander_ui/tui.dart';
import 'package:vigie/vigie.dart';

void renderPrompt(RenderContext ctx, TextPrompt p, Rect area) {
  const boxWidth = 56;
  const boxHeight = 7;
  final box = Rect(
    area.x + ((area.width - boxWidth) ~/ 2).clamp(0, area.width),
    area.y + ((area.height - boxHeight) ~/ 2).clamp(0, area.height),
    boxWidth.clamp(0, area.width),
    boxHeight.clamp(0, area.height),
  );

  final shown = p.obscure ? '•' * p.value.length : p.value;
  final text = StringBuffer()
  ..writeln('${p.label} :')
  ..writeln('> $shown');

  ctx.draw(
    Container(
      border: BorderStyle.rounded,
      title: p.title,
      padding: const EdgeInsets(left: 2, right: 2, top: 1),
      child: Paragraph(text.toString()),
    ),
    box
  );

  final err = p.error;
  if (err != null) {
    ctx.draw(
      Text(err, style: const Style(fg: Color.red)),
      Rect(box.x + 3, box.y + 5, box.width - 5, 1),
    );
  }
}