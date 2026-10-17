import 'package:test/test.dart';
import 'package:vigie/src/system/overview.dart';

void main() {
  group('History.push', () {
    test('keeps every value below the limit', () {
      final h = History(max: 3)
        ..push(1)
        ..push(2);
      expect(h.values, [1, 2]);
    });
    test('drops the oldest values beyond the limit', () {
      final h = History(max: 3)
        ..push(1)
        ..push(2)
        ..push(3)
        ..push(4)
        ..push(5);
      expect(h.values, [3, 4, 5]);
    });
  });
}
