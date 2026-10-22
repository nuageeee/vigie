import 'package:test/test.dart';
import 'package:vigie/src/system/thermal.dart';

void main() {
  group('parseTemperature', () {
    test('converts millidegrees to degrees', () {
      expect(parseTemperature('47000'), 47.0);
    });
    test('ignores the trailing newline', () {
      expect(parseTemperature('47000\n'), 47.0);
    });
    test('keeps decimals', () {
      expect(parseTemperature('47500'), 47.5);
    });
    test('returns null for invalid text', () {
      expect(parseTemperature('abc'), isNull);
    });
    test('returns null for empty text', () {
      expect(parseTemperature(''), isNull);
    });
  });

  group('pickCpuTemperature', () {
    test('picks the AMD sensor', () {
      expect(
        pickCpuTemperature([
          ('acpitz', '54000'),
          ('amdgpu', '45000'),
          ('k10temp', '48000'),
        ]),
        48.0,
      );
    });
    test('picks the Intel package sensor', () {
      expect(
        pickCpuTemperature([('acpitz', '30000'), ('x86_pkg_temp', '47000')]),
        47.0,
      );
    });

    test('picks the Intel hwmon sensor', () {
      expect(
        pickCpuTemperature([('acpitz', '30000'), ('coretemp', '45000')]),
        45.0,
      );
    });

    test('picks the Raspberry Pi sensor', () {
      expect(pickCpuTemperature([('cpu-thermal', '52000')]), 52.0);
    });

    test('prefers the first known sensor', () {
      expect(
        pickCpuTemperature([('coretemp', '45000'), ('x86_pkg_temp', '47000')]),
        45.0,
      );
    });
  });
}
