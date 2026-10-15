import 'package:test/test.dart';
import 'package:vigie/src/system/guards.dart';

void main() {
  group('checkServiceTarget', () {
    test('refuses targeting SSH service in SSH', () {
      final env = {'SSH_CONNECTION': '203.0.113.5 52344 10.0.0.1 22'};
      expect(
        checkServiceTarget(env, 'ssh.socket', []),
        RefusalReason.sshLockout,
      );
    });
    test('allows targeting sshguard in SSH', () {
      final env = {'SSH_CONNECTION': '203.0.113.5 52344 10.0.0.1 22'};
      expect(checkServiceTarget(env, 'sshguard', []), isNull);
    });
    test('allows targeting nginx in SSH', () {
      final env = {'SSH_CONNECTION': '203.0.113.5 52344 10.0.0.1 22'};
      expect(checkServiceTarget(env, 'nginx', []), isNull);
    });
    test('allows targeting ssh in a local session', () {
      final env = {'HOME': '/home'};
      expect(checkServiceTarget(env, 'sshd', []), isNull);
    });
  });

  // VPS, connected in SSH
  const sshChain = [
    'systemd',
    'sshd',
    'sshd-session',
    'sshd-session',
    'bash',
    'sudo',
    'sudo',
    'dart:vigie.dart',
  ];

  // WSL, local terminal
  const localChain = [
    'systemd',
    'init-systemd(Ub',
    'SessionLeader',
    'Relay(833)',
    'bash',
    'sudo',
    'sudo',
    'dart:vigie',
  ];

  group('hasSshAncestor', () {
    test('detects an SSH session among the ancestors', () {
      expect(hasSshAncestor(sshChain), isTrue);
    });
    test('returns false in a local terminal', () {
      expect(hasSshAncestor(localChain), isFalse);
    });
    test('ignores processes with a similar name', () {
      const lookalikeChain = [
        'systemd',
        'init-systemd(Ub',
        'SessionLeader',
        'Relay(833)',
        'sshguard',
        'bash',
        'sudo',
        'sudo',
        'dart:vigie',
      ];
      expect(hasSshAncestor(lookalikeChain), isFalse);
    });
  });
}
