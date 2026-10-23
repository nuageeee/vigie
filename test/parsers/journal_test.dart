import 'package:test/test.dart';

const journal =
    '''{"__REALTIME_TIMESTAMP":"1761122463000000","PRIORITY":"6","SYSLOG_IDENTIFIER":"sshd","MESSAGE":"Accepted publickey for nuage from 203.0.113.7"}''';

void main() {
  group('parseJournalLine', () {
    test('reads every field of a complete entry', () {
      final j = parseJournalLine(journal);
      expect(j.date?.microsecondsSinceEpoch, 1761122463000000);
    });
  });
}
