import 'package:test/test.dart';
import 'package:vigie/src/system/guards.dart';

void main() {
  group('checkProcessTarget', () {
    test('refuses killing PID 1', () {
      expect(checkProcessTarget(1, 4242), RefusalReason.initTarget);
    });
    test('refuses killing vigie itself', () {
      expect(checkProcessTarget(4242, 4242), RefusalReason.vigieTarget);
    });
    test('allows killing another process', () {
      expect(checkProcessTarget(1234, 4242), isNull);
    });
  });
}
