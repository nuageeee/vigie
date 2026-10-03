import 'dart:async';

import 'package:commander_ui/tui.dart';
import 'package:vigie/src/system/overview.dart';
import 'package:vigie/src/system/shell.dart';

enum Section {
  table('Dashboard'),
  users('Users'),
  process('Process'),
  services('Services');

  final String label;
  const Section(this.label);
}

class PendingAction {
  final String question;
  final Future<CmdResult> Function() run;
  const PendingAction(this.question, this.run);
}

class TextPrompt {
  final String title;
  final String label;
  final bool obscure;
  final String? Function(String value)? validate;
  final Future<CmdResult> Function(String value) onSubmit;
  String value = '';
  String? error;

  TextPrompt({
    required this.title,
    required this.label,
    required this.onSubmit,
    this.obscure = false,
    this.validate,
  });
}

class VigieState {
  final bool isRoot;
  final String AdminGroup;
  final cpu = CpuSampler();

  Section section = Section.table;

  Overview? overview;

  String status = 'Ready !';
  bool statusError = false;
  PendingAction? pending;
  TextPrompt? prompt;

  bool _refreshing = false;
  bool _refreshAgain = false;

  VigieState({required this.isRoot, required this.AdminGroup});

  final events = StreamController<Event>();

  void setStatus(CmdResult r) {
    status = r.message;
    statusError = !r.ok;
  }

  void refreshInBackground({bool all = false}) {
    if (_refreshing) {
      _refreshAgain = true;
      return;
    }
    _refreshing = true;
    refresh(all: all).whenComplete(() {
      _refreshing = false;
      events.add(const CustomEvent('refreshed'));
      if(_refreshAgain) {
        _refreshAgain = false;
        refreshInBackground();
      }
    });
  }

  Future<void> refresh({bool all = false}) async {
    overview = await loadOverview(cpu);
  }
}
