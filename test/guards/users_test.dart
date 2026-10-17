import 'package:test/test.dart';
import 'package:vigie/src/system/guards.dart';

const env = {'SUDO_USER': 'nuage'};

void main() {
  group('RefusalReason', () {
    test('refuses deleting root', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'root',
          uid: 0,
          action: UserAction.delete,
          isAdmin: false,
          adminCount: 2,
        ),
        RefusalReason.rootTarget,
      );
    });
    test('allows locking root', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'root',
          uid: 0,
          action: UserAction.lock,
          isAdmin: false,
          adminCount: 2,
        ),
        isNull,
      );
    });
    test('allows revoking admin from root', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'root',
          uid: 0,
          action: UserAction.revokeAdmin,
          isAdmin: false,
          adminCount: 2,
        ),
        isNull,
      );
    });
    test('root reason wins chen root deletes itself', () {
      final rootEnv = {'SUDO_USER': 'root'};
      expect(
        checkUserTarget(
          env: rootEnv,
          user: 'root',
          uid: 0,
          action: UserAction.delete,
          isAdmin: false,
          adminCount: 2,
        ),
        RefusalReason.rootTarget,
      );
    });
    test('refuses deleting yourself', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'nuage',
          uid: 1000,
          action: UserAction.delete,
          isAdmin: false,
          adminCount: 2,
        ),
        RefusalReason.selfTarget,
      );
    });
    test('refuses locking yourself', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'nuage',
          uid: 1000,
          action: UserAction.lock,
          isAdmin: false,
          adminCount: 2,
        ),
        RefusalReason.selfTarget,
      );
    });
    test('refuses revoking your own admin rights', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'nuage',
          uid: 1000,
          action: UserAction.revokeAdmin,
          isAdmin: false,
          adminCount: 2,
        ),
        RefusalReason.selfTarget,
      );
    });
    test('allows deleting another user', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'bob',
          uid: 1001,
          action: UserAction.delete,
          isAdmin: false,
          adminCount: 2,
        ),
        isNull,
      );
    });
    test('allows actions when not run through sudo', () {
      expect(
        checkUserTarget(
          env: {},
          user: 'bob',
          uid: 1001,
          action: UserAction.delete,
          isAdmin: false,
          adminCount: 2,
        ),
        isNull,
      );
    });
    test('refuses deleting the last admin', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'bob',
          uid: 1001,
          action: UserAction.delete,
          isAdmin: true,
          adminCount: 1,
        ),
        RefusalReason.lastAdmin,
      );
    });
    test('refuses locking the last admin', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'bob',
          uid: 1001,
          action: UserAction.lock,
          isAdmin: true,
          adminCount: 1,
        ),
        RefusalReason.lastAdmin,
      );
    });
    test('refuses revoking the last admin', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'bob',
          uid: 1001,
          action: UserAction.revokeAdmin,
          isAdmin: true,
          adminCount: 1,
        ),
        RefusalReason.lastAdmin,
      );
    });
    test('allows deleting an admin when another remains', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'bob',
          uid: 1001,
          action: UserAction.delete,
          isAdmin: true,
          adminCount: 2,
        ),
        isNull,
      );
    });
    test('allows deleting a non-admin when only one admin exists', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'bob',
          uid: 1001,
          action: UserAction.delete,
          isAdmin: false,
          adminCount: 1,
        ),
        isNull,
      );
    });
    test('last admin reason wins over self-taget', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'nuage',
          uid: 1000,
          action: UserAction.lock,
          isAdmin: true,
          adminCount: 1,
        ),
        RefusalReason.lastAdmin,
      );
    });
    test('root reason wins over last admin', () {
      expect(
        checkUserTarget(
          env: env,
          user: 'root',
          uid: 0,
          action: UserAction.delete,
          isAdmin: true,
          adminCount: 1,
        ),
        RefusalReason.rootTarget,
      );
    });
  });
}
