import 'dart:math';

import 'package:vigie/src/ui/strings.dart';

String formatUptime(Duration d, Strings t) {
  final days = d.inDays;
  final h = d.inHours % 24;
  final m = d.inMinutes % 60;
  return days > 0 ? '$days${t.dayUnit} ${h}h ${m}min' : '${h}h ${m}min';
}

String formatKb(int kb, Strings t) {
  if (kb >= 1024 * 1024) return '${(kb / 1024 / 1024).toStringAsFixed(1)} ${t.byteUnits[3]}';
  if (kb >= 1024) return '${(kb / 1024).toStringAsFixed(0)} ${t.byteUnits[2]}';
  return '$kb ${t.byteUnits[1]}';
}

String formatOc(int oc, Strings t) {
  final unit = t.byteUnits;
  double value = oc.toDouble();
  var i = 0;

  while (value >= 1000 && i < unit.length - 1) {
    value /= 1000;
    i++;
  }

  return '${value.toStringAsFixed(1)} ${unit[i]}/s';
}

List<String> wrapText(String text, int width) {
  final pieces = <String>[];

  if (text.isEmpty || width <= 0) return [text];

  for (var i = 0; i < text.length; i += width) {
    final end = min(i + width, text.length);
    pieces.add(text.substring(i, end));
  }

  return pieces;
}
