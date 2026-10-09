String formatUptime(Duration d) {
  final days = d.inDays;
  final h = d.inHours % 24;
  final m = d.inMinutes % 60;
  return days > 0 ? '${days}j ${h}h ${m}min' : '${h}h ${m}min';
}

String formatKb(int kb) {
  if (kb >= 1024 * 1024) return '${(kb / 1024 / 1024).toStringAsFixed(1)} Go';
  if (kb >= 1024) return '${(kb / 1024).toStringAsFixed(0)} Mo';
  return '$kb Ko';
}

String formatOc(int oc) {
  const unit = ['o', 'Ko', 'Mo', 'Go'];
  double value = oc.toDouble();
  var i = 0;

  while (value >= 1000 && i < unit.length -1) {
    value /= 1000;
    i++;
  }


  return '${value.toStringAsFixed(1)} ${unit[i]}/s';
}