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
    test('picks the AMD sensor', () {
      expect(pickCpuTemperature([('acpitz', '54000'), ('amdgpu', '45000'), ('k10temp', '48000')]), 48.0);
    });
  });
}
