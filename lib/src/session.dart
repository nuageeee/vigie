import 'dart:io';

const shellExitBase = 100;

Future<Never> runSession(List<String> args, String lang) async {
  Process? current;

  ProcessSignal.sigint.watch().listen((_) {});
  ProcessSignal.sigint.watch().listen((_) {
    current?.kill();
    exit(143);
  });

  final self = _selfCommand();
  final userArgs = _withoutOptions(args, const ['--section', '--lang']);
  final rc = _writeRcFile();
  var section = 1;

  while (true) {
    current = await Process.start(
      self.first,
      [...self.skip(1), ...userArgs, '--lang', lang, '--section', '${section}'],
      mode: ProcessStartMode.inheritStdio,
      environment: {'VIGIE_SESSION': '1'}
    );
    final code = await current.exitCode;

    if (code > shellExitBase && code < shellExitBase + 100) {
      section = code - shellExitBase;
      current = await Process.start(
        'bash',
        ['-c', r'read -rs -t 0.1 -n 10000 _ 2>/dev/null; exec bash --rcfile "$1" -i', 'bash', rc.path],
        mode: ProcessStartMode.inheritStdio,
        environment: {'VIGIE_SESSION': '1'},
      );
      await current.exitCode;
    } else {
      try { rc.deleteSync(); } catch (_) {}
      exit(code);
    }
  }
}

List<String> _selfCommand() {
  final exe = Platform.resolvedExecutable;
  final viaDart = exe.endsWith('/dart');
  return viaDart ? [exe, Platform.script.toFilePath()] : [exe];
}

List<String> _withoutOptions(List<String> args, List<String> options) {
  final out = <String>[];
  for (var i = 0; i < args.length; i++) {
    if (options.contains(args[i])) { i++; continue; }
    out.add(args[i]);
  }
  return out;
}

File _writeRcFile() {
  final f = File('${Directory.systemTemp.path}/vigie-bashrc-$pid');
  f.writeAsStringSync(
    '[ -f ~/.bashrc ] && . ~/.bashrc\n'
    r'PS1="\[\e[35m\](vigie)\[\e[0m\] $PS1"' '\n',
  );
  return f;
}