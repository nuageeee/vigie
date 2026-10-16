import 'dart:io';

import 'package:commander_ui/tui.dart';
import 'package:vigie/src/system/guards.dart';
import 'package:vigie/src/system/processes.dart';
import 'package:vigie/src/system/services.dart';
import 'package:vigie/src/system/shell.dart';
import 'package:vigie/src/system/users.dart';
import 'package:vigie/vigie.dart';

Future<void> onEvent(VigieState s, Event event, RunHandle handle) async {
  if (event is TickEvent) {
    if (s.prompt == null) s.refreshInBackground();
    return;
  }

  if (event is CustomEvent) {
    handle.requestRedraw();
    return;
  }

  if (event is MouseEvent) {
    await _handleClick(s, event, handle);
    return;
  }

  if (event is! KeyEvent) return;

  final prompt = s.prompt;
  if (prompt != null) {
    await _handlePrompt(s, prompt, event);
    handle.requestRedraw();
    return;
  }

  final pending = s.pending;
  if (pending != null) {
    if (event.char == 'o' || event.char == 'y') {
      s.pending = null;
      s.setResult(await pending.run(), pending.done);
      s.refreshInBackground();
    } else if (event.char == 'n' || event.key == NamedKey.escape) {
      s.pending = null;
      s.setMessage(s.t.cancelled);
    }
    handle.requestRedraw();
    return;
  }

  // 3. Raccourcis globaux.
  if (event.char == 'q') {
    handle.stop();
    return;
  }

  if (event.char == '!') {
    s.openShell = true;
    handle.stop();
    return;
  }

  final digit = int.tryParse(event.char ?? '');
  if (digit != null && digit >= 1 && digit <= Section.values.length) {
    s.section = Section.values[digit - 1];
    s.setMessage(s.t.ready);
    handle.requestRedraw(); // changement de section instantané
    s.refreshInBackground();
    return;
  }
  if (event.key == NamedKey.f5) {
    s.refreshInBackground(all: true);
    s.setMessage(s.t.refreshing);
    handle.requestRedraw();
    return;
  }

  // 4. Raccourcis propres à la section.
  final c = event.char;
  if (c == null) return;
  switch (s.section) {
    case Section.services:
      _serviceKeys(s, c);
    case Section.process:
      _processKeys(s, c);
    case Section.users:
      _userKeys(s, c);
    case Section.table:
      break;
  }
  handle.requestRedraw();
}

bool _requireRoot(VigieState s) {
  if (s.isRoot) return true;
  s.setMessage(s.t.rootRequired, error: true);
  return false;
}

void _ask(
  VigieState s,
  String question,
  Future<CmdResult> Function() run,
  String done,
) {
  if (_requireRoot(s)) s.pending = PendingAction(question, run, done);
}

void _serviceKeys(VigieState s, String c) {
  const riskyOnSsh = {'stop', 'disable', 'restart'};

  final svc = s.selectedService;
  if (svc == null) return;
  final n = svc.name;
  final (verb, question, done) = switch (c) {
    's' => ('start', s.t.askStart(n), s.t.serviceStarted(n)),
    'x' => ('stop', s.t.askStop(n), s.t.serviceStopped(n)),
    'r' => ('restart', s.t.askRestart(n), s.t.serviceRestarted(n)),
    'e' => ('enable', s.t.askEnable(n), s.t.serviceEnabled(n)),
    'd' => ('disable', s.t.askDisable(n), s.t.serviceDisabled(n)),
    _ => ('', '', ''),
  };
  if (verb.isEmpty) return;

  final reason = riskyOnSsh.contains(verb)
      ? checkServiceTarget(Platform.environment, n, readAncestorNames())
      : null;

  if (reason != null) {
    s.setMessage(s.t.refusalMessage(reason, s.t.verb(verb), n), error: true);
    return;
  }
  _ask(s, question, () async {
    final result = await serviceAction(verb, svc);
    invalidateServices();
    return result;
  }, done);
}

void _processKeys(VigieState s, String c) {
  final vigiePid = pid;
  final p = s.selectedProcess;
  if (p == null) return;
  final (verb, question, done, force) = switch (c) {
    't' => (
      'term',
      s.t.askTerm(p.command, p.pid),
      s.t.processTermSent(p.command, p.pid),
      false,
    ),
    'K' => (
      'kill',
      s.t.askKill(p.command, p.pid),
      s.t.processKilled(p.command, p.pid),
      true,
    ),
    _ => ('', '', '', false),
  };
  if (verb.isEmpty) return;
  final reason = checkProcessTarget(p.pid, vigiePid);

  if (reason != null) {
    s.setMessage(s.t.refusalMessage(reason, s.t.verb(verb), p.command), error: true);
    return;
  }
  _ask(s, question, () {
    final result = killProcess(p, force: force);
    return result;
  }, done);
}

void _userKeys(VigieState s, String c) {
  final u = s.selectedUser;
  switch (c) {
    case 'a':
      if (!_requireRoot(s)) return;
      s.prompt = TextPrompt(
        title: s.t.newUserTitle,
        label: s.t.newUserLabel,
        validate: (v) => usernamePattern.hasMatch(v) ? null : s.t.usernameRule,
        onSubmit: addUser,
        done: s.t.userCreated,
      );
    case 'p' when u != null:
      if (!_requireRoot(s)) return;
      s.prompt = TextPrompt(
        title: s.t.passwordTitle(u.name),
        label: s.t.passwordLabel,
        obscure: true,
        validate: (v) => v.length >= 8 ? null : s.t.passwordRule,
        onSubmit: (v) => setPassword(u, v),
        done: (_) => s.t.passwordChanged(u.name),
      );
    case 'v' when u != null:
      const action = UserAction.lock;
      final unlock = u.locked == true;
      final reason = checkUserTarget(
        Platform.environment,
        u.name,
        u.uid,
        action,
      );
      if (reason != null && !unlock) {
        s.setMessage(
          s.t.refusalMessage(reason, s.t.verb(action.name), u.name),
          error: true,
        );
        return;
      }
    case 'g' when u != null:
      const action = UserAction.revokeAdmin;
      final isIn = u.groups.contains(s.adminGroup);
      final reason = checkUserTarget(
        Platform.environment,
        u.name,
        u.uid,
        action,
      );
      if (reason != null && isIn) {
        s.setMessage(
          s.t.refusalMessage(reason, s.t.verb(action.name), u.name),
          error: true,
        );
        return;
      }
    case 'D' when u != null:
      const action = UserAction.delete;
      final reason = checkUserTarget(
        Platform.environment,
        u.name,
        u.uid,
        action,
      );
      if (reason != null) {
        s.setMessage(
          s.t.refusalMessage(reason, s.t.verb(action.name), u.name),
          error: true,
        );
        return;
      }
  }
}

Future<void> _handlePrompt(VigieState s, TextPrompt p, KeyEvent e) async {
  if (e.key == NamedKey.escape) {
    s.prompt = null;
    s.setMessage(s.t.cancelled);
  } else if (e.key == NamedKey.backspace) {
    if (p.value.isNotEmpty) p.value = p.value.substring(0, p.value.length - 1);
    p.error = null;
  } else if (e.key == NamedKey.enter) {
    final err = p.validate?.call(p.value);
    if (err != null) {
      p.error = err;
      return;
    }
    s.prompt = null;
    s.setResult(await p.onSubmit(p.value), p.done(p.value));
    s.refreshInBackground();
  } else if (e.char != null && !e.ctrl && !e.alt) {
    p.value += e.char!;
    p.error = null;
  }
}

Future<void> _handleClick(VigieState s, MouseEvent e, RunHandle handle) async {
  if (e.action != MouseAction.down || e.button != MouseButton.left) return;
  if (s.prompt != null) return;

  for (final zone in s.clickZones.reversed) {
    if (!zone.rect.contains(e.x, e.y)) continue;
    final key = zone.key;
    if (key != null) {
      await onEvent(s, key, handle);
    } else {
      zone.onClick?.call(e.x, e.y);
      handle.requestRedraw();
    }
    return;
  }
}
