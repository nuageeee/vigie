import 'dart:async';

import 'package:commander_ui/tui.dart';
import 'package:vigie/src/system/overview.dart';
import 'package:vigie/src/system/processes.dart';
import 'package:vigie/src/system/services.dart';
import 'package:vigie/src/system/shell.dart';
import 'package:vigie/src/system/users.dart';
import 'package:vigie/src/ui/strings.dart';

enum Section { table, users, process, services }

class PendingAction {
  final String question;
  final Future<CmdResult> Function() run;
  final String? done;
  const PendingAction(this.question, this.run, [this.done]);
}

class TextPrompt {
  final String title;
  final String label;
  final bool obscure;
  final String? Function(String value)? validate;
  final Future<CmdResult> Function(String value) onSubmit;
  final String Function(String value)? done;
  String value = '';
  String? error;

  TextPrompt({
    required this.title,
    required this.label,
    required this.onSubmit,
    this.done,
    this.obscure = false,
    this.validate,
  });
}

class ClickZone {
  final Rect rect;
  final KeyEvent? key;
  final void Function(int x, int y)? onClick;
  const ClickZone(this.rect, {this.key, this.onClick});
}

class VigieState {
  final bool isRoot;
  final String AdminGroup;
  final Strings t;

  final cpu = CpuSampler();
  final net = Network();
  final procSampler = ProcSampler();

  bool openShell = false;

  Section section = Section.table;

  Overview? overview;
  List<SysUser> users = [];
  List<Proc> processes = [];
  List<Service> services = [];

  final usersTable = TableState<SysUser>();
  final processesTable = TableState<Proc>();
  final servicesTable = TableState<Service>();

  late String status = t.ready;
  bool statusError = false;
  PendingAction? pending;
  TextPrompt? prompt;

  bool _refreshing = false;
  bool _refreshAgain = false;

  final clickZones =  <ClickZone>[];

  VigieState({
    required this.isRoot,
    required this.AdminGroup,
    required this.t,
  });

  final events = StreamController<Event>();

  void setStatus(CmdResult r, [String? done]) {
    status = r.message ?? (r.ok ? done ?? '' : t.failure(r));
    statusError = !r.ok;
  }

  T? _selected<T>(List<T> items, TableState<T> table) {
    if (items.isEmpty) return null;
    return items[table.activeRow.clamp(0, items.length - 1)];
  }

  SysUser? get selectedUser => _selected(users, usersTable);
  Proc? get selectedProcess => _selected(processes, processesTable);
  Service? get selectedService => _selected(services, servicesTable);

  void refreshInBackground({bool all = false}) {
    if (_refreshing) {
      _refreshAgain = true;
      return;
    }
    _refreshing = true;
    refresh(all: all).whenComplete(() {
      _refreshing = false;
      events.add(const CustomEvent('refreshed'));
      if (_refreshAgain) {
        _refreshAgain = false;
        refreshInBackground();
      }
    });
  }

  Future<void> refresh({bool all = false}) async {
    overview = await loadOverview(cpu, net);
    if (all || section == Section.users) users = await LoadUsers();
    if (all || section == Section.process) processes = await procSampler.sample();
    if (all || section == Section.services || section == Section.table) {
      services = await loadServices();
    }
  } 
}
