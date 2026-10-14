import 'package:test/test.dart';
import 'package:vigie/src/system/services.dart';

void main() {
  const basePid = '''
2730637 (bash) S 2730636 2730637 2730637 34816 2744846 4194304 4285 21255 0 0 9 4 8 26 20 0 1 0 111752805 9887744 1512 18446744073709551615 107501389238272 107501390297505 140729147103104 0 0 0 65536 3686404 1266761467 1 0 0 17 2 0 0 0 0 0 107501390526704 107501390575752 107502255579136 140729147104807 140729147104813 140729147104813 140729147105262 0
''';
  const alteredPid = '''
2730637 (bash S 2730636 2730637 2730637 34816 2744846 4194304 4285 21255 0 0 9 4 8 26 20 0 1 0 111752805 9887744 1512 18446744073709551615 107501389238272 107501390297505 140729147103104 0 0 0 65536 3686404 1266761467 1 0 0 17 2 0 0 0 0 0 107501390526704 107501390575752 107502255579136 140729147104807 140729147104813 140729147104813 140729147105262 0
''';
  const suspectPid = '''
4242 (tmux: server) S 1 4242
''';
  group('parsePpid', () {
    test('returns the parent PID from a real stat line', () {
      expect(parsePpid(basePid), 2730636);
    });
    test('returns null if ) is missing', () {
      expect(parsePpid(alteredPid), isNull);
    });
    test('handles a process name with spaces and parentheses', () {
      expect(parsePpid(suspectPid), 1);
    });
    test('returns null if the line is empty', () {
      expect(parsePpid(''), isNull);
    });
  });
}
