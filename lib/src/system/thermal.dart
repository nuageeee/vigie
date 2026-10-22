import 'dart:io';

import 'package:vigie/src/system/shell.dart';

double? parseTemperature(String text) {
  final n = int.tryParse(text.trim());
  if (n == null) return null;
  return n / 1000;
}

const _tempZones = {'x86_pkg_temp', 'cpu-thermal', 'cpu_thermal'};

double? pickCpuTemperature(List<(String name, String temps)> thermal) {
  for (final (name, temps) in thermal) {
    if (_tempZones.contains(name)) return parseTemperature(temps);
  }
  return null;
}


List<(String, String)> readThermalZones() {
  final dir = Directory('/sys/class/thermal/');
  if (!dir.existsSync()) return [];

  final zones = <(String, String)>[];

  for (final entry in dir.listSync()) {
    final name = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (!name.startsWith('thermal_zone')) continue;
    final type = readFile('${entry.path}/type').trim();
    final temp = readFile('${entry.path}/temp');

    zones.add((type, temp));
  }
  return zones;
}
