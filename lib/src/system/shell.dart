import 'dart:convert';
import 'dart:io';

/// Issue d'une commande, sans texte destiné à l'utilisateur : l'interface
/// rédige le message.
class CmdResult {
  final bool ok;
  final String exe;

  /// Code de sortie, si la commande a pu être lancée.
  final int? exitCode;

  /// Première ligne de stderr (ou de stdout), brute, en cas d'échec.
  final String? output;

  /// Exception levée si la commande n'a pas pu être lancée.
  final Object? error;

  const CmdResult(
    this.ok, {
    required this.exe,
    this.exitCode,
    this.output,
    this.error,
  });
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

      if (code == 0) return CmdResult(true, exe: exe, exitCode: code);
      final msg = (err.trim().isNotEmpty ? err : out).trim().split('\n').first;
      return CmdResult(false, exe: exe, exitCode: code, output: msg);
    } catch (e) {
      return CmdResult(false, exe: exe, error: e);
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