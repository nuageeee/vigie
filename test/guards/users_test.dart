import 'package:test/test.dart';
import 'package:vigie/src/system/guards.dart';

const env = {'SUDO_USER': 'nuage'};

void main() {
  group('RefusalReason', () {
    test('refuses deleting root', () {
      expect(checkUserTarget(env, 'root', 0, 'delete'), RefusalReason.rootTarget);
    });
    test('allows locking root', () {
      expect(checkUserTarget(env, 'root', 0, 'lock'), isNull);
    });
    test('allows revoking admin from root', () {
      expect(checkUserTarget(env, 'root', 0, 'revokeAdmin'), isNull);
    });
    test('root reason wins chen root deletes itself', () {
      final rootEnv = {'SUDO_USER': 'root'};
      expect(checkUserTarget(rootEnv, 'root', 0, 'delete'), RefusalReason.rootTarget);
    });
    test('refuses deleting yourself', () {
      expect(checkUserTarget(env, 'nuage', 1000, 'delete'), RefusalReason.selfTarget);
    });
    test('refuses locking yourself', () {
      expect(checkUserTarget(env, 'nuage', 1000, 'lock'), RefusalReason.selfTarget);
    });
    test('refuses revoking your own admin rights', () {
      expect(checkUserTarget(env, 'nuage', 1000, 'revokeAdmin'), RefusalReason.selfTarget);
    });
    test('allows deleting another user', () {
      expect(checkUserTarget(env, 'bob', 1001, 'delete'), isNull);
    });
    test('allows actions when not run through sudo', () {
      expect(checkUserTarget({}, 'bob', 1001, 'delete'), isNull);
    });
  });
}
