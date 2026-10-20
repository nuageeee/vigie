import 'package:test/test.dart';
import 'package:vigie/src/ui/components/formatters.dart';

void main() {
  group('wrapText', () {
    test('keeps short text on one line', () {
      expect(wrapText('abc', 5), ['abc']);
    });
    test('splits text at the exact widt', () {
      expect(wrapText('abcdef', 3), ['abc', 'def']);
    });
    test('puts the remainder on a shorter last line', () {
      expect(wrapText('abcdefgh', 3), ['abc', 'def', 'gh']);
    });
    test('returns one empty line for empty text', () {
      expect(wrapText('', 5), ['']);
    });
    test('does not split when width is zero or less', () {
      expect(wrapText('abc', 0), ['abc']);
    });
  });
}
