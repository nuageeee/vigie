import 'dart:io';

import 'package:vigie/src/system/shell.dart';

double? parseTemperature(String text) {
  final n = int.tryParse(text.trim());
  if (n == null) return null;
  return n / 1000;
}

const _tempZones = {
  'coretemp',     // Intel (hwmon)
  'k10temp',      // AMD (hwmon)
  'x86_pkg_temp', // Intel (thermal)
  'cpu-thermal',  // Raspberry Pi (thermal)
  'cpu_thermal',  // Raspberry Pi (hwmon / anciens noyaux)
};

double? pickCpuTemperature(List<(String name, String temps)> thermal) {
  for (final (name, temps) in thermal) {
    if (_tempZones.contains(name)) return parseTemperature(temps);
  }
  return null;
}

List<(String, String)> _readSensors(
  String path,
  String prefix,
  String nameFile,
  String tempFile,
) {
  final dir = Directory(path);
  if (!dir.existsSync()) return [];

  final sensors = <(String, String)>[];

  for (final entry in dir.listSync()) {
    final name = entry.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (!name.startsWith(prefix)) continue;
    final type = readFile('${entry.path}/$nameFile').trim();
    final temp = readFile('${entry.path}/$tempFile');
    sensors.add((type, temp));
  }
  return sensors;
}

List<(String, String)> readThermalZones() =>
    _readSensors('/sys/class/thermal', 'thermal_zone', 'type', 'temp');

List<(String, String)> readHwmon() =>
    _readSensors('/sys/class/hwmon', 'hwmon', 'name', 'temp1_input');

/// hwmon d'abord : plus précis (coretemp, k10temp) quand les deux existent.
List<(String, String)> readSensors() => [...readHwmon(), ...readThermalZones()];
