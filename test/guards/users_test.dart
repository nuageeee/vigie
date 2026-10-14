import 'package:test/test.dart';
import 'package:vigie/src/system/users.dart';

void main() {
  group('RefusalReason', () {
    test('refuses targeting your own account', () {
      final env = {'SUDO_USER': 'nuage'};
      expect(checkUserTarget(env, 'nuage'), RefusalReason.selfTarget);
    });
    test('allows targeting another account', () {
      final env = {'SUDO_USER': 'nuage'};
      expect(checkUserTarget(env, 'vigie'), isNull);
    });
    test('allows any target when the sudo user is unknown', () {
      final env = {'HOME': '/home'};
      expect(checkUserTarget(env, 'vigie'), isNull);
    });
  });
}
