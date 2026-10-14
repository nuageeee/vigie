import 'package:test/test.dart';
import 'package:vigie/src/system/processes.dart';

void main() {
  group('processCpuPercent', () {
    test('returns 0 when there is no previous reading', () {
      expect(processCpuPercent(50, 100, null, 1), closeTo(0.0, 0.01));
    });
    test('returns 0 when total delta is zero', () {
      expect(processCpuPercent(20, 0, 10, 1), closeTo(0.0, 0.01));
    });
    test('returns 0 when total delta is negative', () {
      expect(processCpuPercent(20, -5, 10, 1), closeTo(0.0, 0.01));
    });
    test('computes the percentage for a normal case', () {
      expect(processCpuPercent(125, 100, 100, 1), closeTo(25.0, 0.01));
    });
    test('can exceed 100 on several cores', () {
      expect(processCpuPercent(300, 400, 100, 4), closeTo(200.0, 0.01));
    });
  });
}