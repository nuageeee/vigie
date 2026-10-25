import 'dart:convert';

import 'package:vigie/src/system/shell.dart';

enum Gravity { error, warning, normal, debug }

class LogEntry {
  final DateTime? date;
  final int priority;
  final String program;
  final String message;

  const LogEntry(
    this.date,
    this.priority, {
    required this.program,
    required this.message,
  });
}

LogEntry? parseJournalLine(String text) {
  Object? decoded;
  try {
    decoded = jsonDecode(text);
  } catch (_) {
    return null;
  }

  if (decoded is! Map<String, dynamic>) return null;

  final prog = decoded['SYSLOG_IDENTIFIER'];
  final progValue = prog is String ? prog : '';

  final prio = decoded['PRIORITY'];
  final prioValue = prio is String ? int.tryParse(prio) ?? 6 : 6;

  final date = decoded['__REALTIME_TIMESTAMP'];
  final micros = date is String ? int.tryParse(date) : null;
  final finalDate = micros == null
      ? null
      : DateTime.fromMicrosecondsSinceEpoch(micros);

  final message = decoded['MESSAGE'];
  final messageValue = switch (message) {
    final String s => s,
    final List l => utf8.decode(l.cast<int>(), allowMalformed: true),
    _ => '',
  };

  return LogEntry(
    finalDate,
    prioValue,
    program: progValue,
    message: messageValue,
  );
}

class LogSource {
  final String title;
  final List<String> filter;

  const LogSource(this.title, this.filter);

  LogSource.unit(String unit) : this(unit, ['-u', unit]);
  const LogSource.kernel() : this('kernel', const ['-k']);
}

List<String> journalArgs(LogSource source, {int lines = 200}) {
  return [...source.filter, '-n', '$lines', '-o', 'json', '--no-pager'];
}

Gravity levelOf(int priority) => switch (priority) {
  <= 3 => Gravity.error,
  4 => Gravity.warning,
  7 => Gravity.debug,
  _ => Gravity.normal,
};

Future<List<LogEntry>> loadJournal(LogSource source) async {
  final journal = await capture('journalctl', journalArgs(source));
  return journal.split('\n').map(parseJournalLine).whereType<LogEntry>().toList();
}
