import 'package:commander_ui/tui.dart';
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

  if (event is! KeyEvent) return;

  final prompt = s.prompt;
  if (prompt != null) {
    await _handlePrompt(s, prompt, event);
    return;
  }

    final pending = s.pending;
  if (pending != null) {
    if (event.char == 'o' || event.char == 'y') {
      s.pending = null;
      s.setStatus(await pending.run());
      s.refreshInBackground();
    } else if (event.char == 'n' || event.key == NamedKey.escape) {
      s.pending = null;
      s.setStatus(const CmdResult(true, 'Annulé'));
    }
    handle.requestRedraw();
    return;
  }

  // 3. Raccourcis globaux.
  if (event.char == 'q') {
    handle.stop();
    return;
  }
  final digit = int.tryParse(event.char ?? '');
  if (digit != null && digit >= 1 && digit <= Section.values.length) {
    s.section = Section.values[digit - 1];
    s.status = 'Prêt';
    s.statusError = false;
    handle.requestRedraw(); // changement de section instantané
    s.refreshInBackground();
    return;
  }
  if (event.key == NamedKey.f5) {
    s.refreshInBackground(all: true);
    s.setStatus(const CmdResult(true, 'Rafraîchissement...'));
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
  s.setStatus(
      const CmdResult(false, 'Action impossible : relance Vigie avec sudo'));
  return false;
}

void _ask(VigieState s, String question, Future<CmdResult> Function() run) {
  if (_requireRoot(s)) s.pending = PendingAction(question, run);
}

void _serviceKeys(VigieState s, String c) {
  final svc = s.selectedService;
  if (svc == null) return;
  final (verb, question) = switch (c) {
    's' => ('start', 'Démarrer ${svc.name} ?'),
    'x' => ('stop', 'Arrêter ${svc.name} ?'),
    'r' => ('restart', 'Redémarrer ${svc.name} ?'),
    'e' => ('enable', 'Activer ${svc.name} au démarrage ?'),
    'd' => ('disable', 'Désactiver ${svc.name} au démarrage ?'),
    _ => ('', ''),
  };
  if (verb.isEmpty) return;
  _ask(s, question, () => serviceAction(verb, svc));
}

void _processKeys(VigieState s, String c) {
  final p = s.selectedProcess;
  if (p == null) return;
  if (c == 't') {
    _ask(s, 'Demander l\'arrêt de ${p.command} (PID ${p.pid}) ?',
        () => killProcess(p));
  } else if (c == 'K') {
    _ask(s, 'TUER ${p.command} (PID ${p.pid}) sans sommation ?',
        () => killProcess(p, force: true));
  }
}

void _userKeys(VigieState s, String c) {
  final u = s.selectedUser;
  switch (c) {
    case 'a':
      if (!_requireRoot(s)) return;
      s.prompt = TextPrompt(
        title: ' Nouvel utilisateur ',
        label: 'Nom',
        validate: (v) => usernamePattern.hasMatch(v)
            ? null
            : 'Minuscules, chiffres, - et _ uniquement (32 max)',
        onSubmit: addUser,
      );
    case 'p' when u != null:
      if (!_requireRoot(s)) return;
      s.prompt = TextPrompt(
        title: ' Mot de passe de ${u.name} ',
        label: 'Nouveau mot de passe',
        obscure: true,
        validate: (v) => v.length >= 8 ? null : '8 caractères minimum',
        onSubmit: (v) => setPassword(u, v),
      );
    case 'v' when u != null:
      _ask(s, '${u.locked == true ? 'Déverrouiller' : 'Verrouiller'} ${u.name} ?',
          () => toggleLock(u));
    case 'g' when u != null:
      final isIn = u.groups.contains(s.AdminGroup);
      _ask(
          s,
          isIn
              ? 'Retirer les droits admin (${s.AdminGroup}) à ${u.name} ?'
              : 'Donner les droits admin (${s.AdminGroup}) à ${u.name} ?',
          () => toggleAdmin(u, s.AdminGroup));
    case 'D' when u != null:
      if (u.uid == 0) {
        s.setStatus(const CmdResult(false, 'On ne supprime pas root 🙂'));
        return;
      }
      _ask(s, 'SUPPRIMER ${u.name} et son dossier ${u.home} ?',
          () => deleteUser(u));
  }
}

Future<void> _handlePrompt(VigieState s, TextPrompt p, KeyEvent e) async {
  if (e.key == NamedKey.escape) {
    s.prompt = null;
    s.setStatus(const CmdResult(true, 'Annulé'));
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
    s.setStatus(await p.onSubmit(p.value));
    s.refreshInBackground();
  } else if (e.char != null && !e.ctrl && !e.alt) {
    p.value += e.char!;
    p.error = null;
  }
}