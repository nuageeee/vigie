import 'dart:convert';
import 'dart:io';

class CmdResult {
  final bool ok;
  final String message;
  const CmdResult(this.ok, this.message);
}

Future<String> capture(String exe, List<String> args) async {
  try {
    final r = await Process.run(exe, args);
    return r.exitCode == 0 ? r.stdout.toString() : '';
  } catch (_) {
    return '';
  }
}

Future<CmdResult> run(
  String exe,
  List<String> args, {
    required String success,
    String? stdinData,
  }) async {
    try {
      final p = await Process.start(exe, args);
      if (stdinData != null) {
        p.stdin.write(stdinData);
      }
      await p.stdin.close();

      final outFuture = p.stdout.transform(utf8.decoder).join();
      final errFuture = p.stderr.transform(utf8.decoder).join();
      final out = await outFuture;
      final err = await errFuture;
      final code = await p.exitCode;

      if (code == 0) return CmdResult(true, success);
      final msg = (err.trim().isNotEmpty ? err : out).trim().split('\n').first;
      return CmdResult(false, msg.isEmpty ? '$exe has failed (code : $code)' : msg);
    } catch (e) {
      return CmdResult(false, 'Impossible to launch $exe : $e');
    }
  }

String readFile(String path) {
  try {
    return File(path).readAsStringSync();
  } catch (_) {
    return '';
  }
}

final _ws = RegExp(r'\s+');

List<String> splitColumns(String line, int count) {
  final parts = line.trim().split(_ws);
  if (parts.length <= count) return parts;
  return [...parts.take(count - 1), parts.skip(count - 1).join('  ')];
}