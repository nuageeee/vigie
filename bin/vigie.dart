import 'dart:io';

import 'package:commander_ui/tui.dart';
import 'package:vigie/src/session.dart';
import 'package:vigie/src/system/services.dart';
import 'package:vigie/src/ui/strings.dart';
import 'package:vigie/vigie.dart';
import 'package:vigie/src/system/shell.dart';
import 'package:vigie/src/system/users.dart';

String? _optionValue(List<String> args, String name) {
  final i = args.indexOf(name);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
}

Future<void> main(List<String> args) async {
  final mouse = !args.contains('--no-mouse');
  final lang = langCode(_optionValue(args, '--lang') ?? Platform.localeName);
  final t = stringsFor(lang);

  if (Platform.environment['VIGIE_SESSION'] == null &&
      !args.contains('--no-session')) {
    await runSession(args, lang);
  }

  if (!Platform.isLinux) {
    stderr.writeln(t.notLinux);
    exit(1);
  }

  for (final sig in [ProcessSignal.sigterm, ProcessSignal.sighup, ProcessSignal.sigint]) {
    sig.watch().listen((_) {
      restoreTerminal();
      exit(0);
    });
  }

  final isRoot = (await capture('id', ['-u'])).trim() == '0';
  final state = VigieState(
    isRoot: isRoot,
    adminGroup: detectAdminGroup(),
    t: t,
    serviceManager: detectServiceManager((path) => Directory(path).existsSync()),
  );
  await state.refresh(all: true);

  if (!isRoot) {
    state.setMessage(t.readOnly, error: true);
  }

  final i = args.indexOf('--section');
  if (i >= 0 && i + 1 < args.length) {
    final n = int.tryParse(args[i + 1]);
    if (n != null && n >= 1 && n <= Section.values.length) {
      state.section = Section.values[n - 1];
    }
  }

  try {
    await runTerminal<VigieState>(
      initialState: state,
      mode: const RenderMode.alternateScreen(),
      frameRate: const Duration(seconds: 2),
      enableMouse: mouse,
      render: render,
      onEvent: onEvent,
    );
  } finally {
    restoreTerminal();
  }
  exit(state.openShell ? shellExitBase + state.section.index + 1 : 0);
}
