import 'package:test/test.dart';
import 'package:vigie/src/system/overview.dart';

void main() {
  group('cpuUsagePercent', () {
    test('return 0 when total delta is zero', () {
      expect(cpuUsagePercent(0, 0), closeTo(0.0, 0.01));
    });
    test('return 0 when total delta is negative', () {
      expect(cpuUsagePercent(10, -5), closeTo(0.0, 0.01));
    });
    test('return 100 when the CPU never idled', () {
      expect(cpuUsagePercent(0, 100), closeTo(100.0, 0.01));
    });
    test('return 0 when the CPU only idled', () {
      expect(cpuUsagePercent(100, 100), closeTo(0, 0.01));
    });
    test('computes the percentage for a normal case', () {
      expect(cpuUsagePercent(75, 100), closeTo(25.0, 0.01));
    });
  });
}