import 'dart:io';

import 'package:commander_ui/tui.dart';
import 'package:vigie/vigie.dart';
import 'package:vigie/src/system/shell.dart';
import 'package:vigie/src/system/users.dart';

void restoreTerminal() {
  stdout.write(
    '\x1b[?1000l\x1b[?1002l\x1b[?1003l\x1b[?1006l\x1b[?1015l' // souris off
    '\x1b[?25h' // curseur visible
    '\x1b[?1049l',
  ); // quitte l'écran alternatif
  try {
    stdin.echoMode = true;
    stdin.lineMode = true;
  } catch (_) {}
}

Future<void> main(List<String> args) async {
  final mouse = !args.contains('--no-mouse');

  if (!Platform.isLinux) {
    stderr.writeln('Vigie only work on linux.');
    exit(1);
  }

  for (final sig in [ProcessSignal.sigterm, ProcessSignal.sighup]) {
    sig.watch().listen((_) {
      restoreTerminal();
      exit(0);
    });
  }

  final isRoot = (await capture('id', ['-u'])).trim() == '0';
  final state = VigieState(isRoot: isRoot, AdminGroup: detectAdminGroup());
  await state.refresh(all: true);

  if (!isRoot) {
    state.status = 'Read-only mode : start "sudo vigie" to act on the system';
    state.statusError = true;
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
  exit(state.openShell ? 42 : 0);
}
