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
  });
}
