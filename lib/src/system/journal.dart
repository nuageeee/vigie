import 'dart:convert';

class LogEntry {
  final DateTime? date;
  final int priority;
  final String program;
  final String message;

  const LogEntry(this.date, this.priority, {required this.program, required this.message});
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
  final dateValue = date is String ? int.tryParse(date) ?? DateTime.fromMicrosecondsSinceEpoch(date) : null;

  

  return null;
}
