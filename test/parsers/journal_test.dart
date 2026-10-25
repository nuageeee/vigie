import 'package:test/test.dart';
import 'package:vigie/src/system/journal.dart';

const journal =
    '''{"__REALTIME_TIMESTAMP":"1761122463000000","PRIORITY":"6","SYSLOG_IDENTIFIER":"sshd","MESSAGE":"Accepted publickey for nuage from 203.0.113.7"}''';

void main() {
  group('parseJournalLine', () {
    test('reads every field of a complete entry', () {
      final j = parseJournalLine(journal);
      expect(j!.date!.microsecondsSinceEpoch, 1761122463000000);
      expect(j.priority, 6);
      expect(j.program, 'sshd');
      expect(j.message, 'Accepted publickey for nuage from 203.0.113.7');
    });
    test('decodes a message sent as bytes', () {
      expect(parseJournalLine('{"MESSAGE":[72,105]}')!.message, 'Hi');
    });
    test('uses defaults for missing fields', () {
      expect(parseJournalLine('{"MESSAGE":"hello"}')!.message, 'hello');
      expect(parseJournalLine('{"MESSAGE":"hello"}')!.priority, 6);
      expect(parseJournalLine('{"MESSAGE":"hello"}')!.program, '');
      expect(parseJournalLine('{"MESSAGE":"hello"}')!.date, isNull);
    });
    test('uses the default priority when it is not a number', () {
      expect(parseJournalLine('{"PRIORITY":"x", "MESSAGE":"m"}')!.priority, 6);
    });
    test('returns null for invalid json', () {
      expect(parseJournalLine('not json'), isNull);
    });

    test('returns null for an empty line', () {
      expect(parseJournalLine(''), isNull);
    });

    test('returns null for json that is not an object', () {
      expect(parseJournalLine('[1, 2]'), isNull);
    });
  });

  group('journalArgs', () {
    test('filters on aa unit', () {
      expect(journalArgs(LogSource.unit('ssh')), [
        '-u',
        'ssh',
        '-n',
        '200',
        '-o',
        'json',
        '--no-pager',
      ]);
    });
    test('reads the kernel', () {
      expect(journalArgs(const LogSource.kernel()), ['-k', '-n', '200', '-o', 'json', '--no-pager']);
    });
    test('uses the requested number of lines', () {
      expect(journalArgs(LogSource.unit('ssh'), lines: 50), contains('50'));
    });
  });

  group('levelOf', () {
    test('treats 0 to 3 as errors', () {
      expect(levelOf(0), Gravity.error);
      expect(levelOf(3), Gravity.error);
    });
    test('treats 4 as warning', () {
      expect(levelOf(4), Gravity.warning);
    });
    test('treats 5 and 6 as normal', () {
      expect(levelOf(5), Gravity.normal);
      expect(levelOf(6), Gravity.normal);
    });
    test('treats 7 as debug', () {
      expect(levelOf(7), Gravity.debug);
    });
  });
}
