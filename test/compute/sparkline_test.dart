import 'package:test/test.dart';
import 'package:vigie/src/ui/components/components.dart';

void main() {
  group('formatHistory', () {
    test('returns 0 to bottom and max to top', () {
      expect(formatHistory([0, 10], 2), '▁█');
    });
    test('returns base line when 0', () {
      expect(formatHistory([0, 0, 0], 3), '▁▁▁');
    });
    test('returns only the recent value', () {
      expect(formatHistory([10, 0, 0, 0, 0], 3), '▁▁▁');
    });
    test('returns empty chain for empty list', () {
      expect(formatHistory([], 2), '');
    });
    test('uses the fixed ceilling when given', () {
      expect(formatHistory([16, 16, 16], 3, maxValue: 100), '▂▂▂');
    });
    test('scales against the ceiling, not the max', () {
      expect(formatHistory([50, 100], 2, maxValue: 100), '▄█');
    });
    test('clamps values above the ceiling', () {
      expect(formatHistory([120], 1, maxValue: 100), '█');
    });
  });
}
