import 'dart:io';

const shellExitBase = 100;

Future<Never> runSession(List<String> args, String lang) async {
  Process? current;

  final self = _selfCommand();
  final userArgs = _withoutOptions(args, const ['--section', '--lang']);
  final rc = _writeRcFile();
  var section = 1;

  ProcessSignal.sigint.watch().listen((_) {});
  ProcessSignal.sigterm.watch().listen((_) {
    current?.kill();
    _removeRcDir(rc);
    exit(143);
  });
  ProcessSignal.sighup.watch().listen((_) {
    current?.kill();
    _removeRcDir(rc);
    exit(129);
  });

  while (true) {
    current = await Process.start(
      self.first,
      [...self.skip(1), ...userArgs, '--lang', lang, '--section', '$section'],
      mode: ProcessStartMode.inheritStdio,
      environment: {'VIGIE_SESSION': '1'},
    );
    final code = await current.exitCode;

    if (code > shellExitBase && code < shellExitBase + 100) {
      section = code - shellExitBase;
      current = await Process.start(
        'bash',
        [
          '-c',
          r'read -rs -t 0.1 -n 10000 _ 2>/dev/null; exec bash --rcfile "$1" -i',
          'bash',
          rc.path,
        ],
        mode: ProcessStartMode.inheritStdio,
        environment: {'VIGIE_SESSION': '1'},
      );
      await current.exitCode;
    } else {
      _removeRcDir(rc);
      exit(0);
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
    if (options.contains(args[i])) {
      i++;
      continue;
    }
    out.add(args[i]);
  }
  return out;
}

File _writeRcFile() {
  final dir = Directory.systemTemp.createTempSync('vigie-');
  final f = File('${dir.path}/vigie-bashrc');
  try {
    final result = Process.runSync('chmod', ['700', (dir.path)]);
    if (result.exitCode != 0) {
      return f;
    }
  } catch (_) {
    return f;
  }
  f.writeAsStringSync(
    '[ -f ~/.bashrc ] && . ~/.bashrc\n'
    r'PS1="\[\e[35m\](vigie)\[\e[0m\] $PS1"'
    '\n',
  );
  return f;
}

void _removeRcDir(File rcFile) {
  final dir = rcFile.parent;
  try {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  } catch (_) {}
}
