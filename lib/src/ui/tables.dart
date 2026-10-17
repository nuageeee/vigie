import 'package:commander_ui/tui.dart';
import 'package:vigie/src/ui/components/formatters.dart';

import '../state.dart';
import '../system/processes.dart';
import '../system/services.dart';
import '../system/users.dart';

Widget _cell(
  String text,
  TableCellState c, {
  Style style = Style.none,
  bool highlight = true,
}) => Text(
  text,
  style: highlight && c.isRowActive && c.isFocused
      ? Style(fg: style.fg, bold: true, reverse: true)
      : style,
);

/// Encadre un tableau et rend ses lignes cliquables.
///
/// Géométrie : bordure (1) + en-tête du tableau (1) + ligne de séparation (1),
/// donc la première ligne de données est 3 lignes sous le haut du cadre.
void _frame<T>(
  RenderContext ctx,
  VigieState s,
  String title,
  Table<T> table,
  TableState<T> tableState,
  int itemCount,
  Rect area,
) {
  final rows = Rect(area.x + 1, area.y + 3, area.width - 2, area.height - 4);
  s.clickZones.add(
    ClickZone(
      rows,
      onClick: (x, y) {
        final index = tableState.verticalScroll + (y - rows.y);
        if (index >= 0 && index < itemCount) tableState.activeRow = index;
      },
    ),
  );

  ctx.draw(
    Container(
      border: BorderStyle.single,
      title: ' $title ',
      padding: const EdgeInsets(left: 1, right: 1),
      child: table,
    ),
    area,
  );
}

// ─── Utilisateurs ──────────────────────────────────────────────────────────

void renderUsers(RenderContext ctx, VigieState s, Rect area) {
  _frame<SysUser>(
    ctx,
    s,
    s.t.usersTitle(s.users.length),
    Table<SysUser>(
      id: Key.symbol(#users),
      items: s.users,
      state: s.usersTable,
      columnSeparator: ' │ ',
      placeholder: s.t.noUsers,
      columns: [
        TableColumn(
          title: s.t.colName,
          width: const TableConstraint.fill(2),
          cellBuilder: (u, c) =>
              _cell(u.name, c, style: const Style(bold: true)),
        ),
        TableColumn(
          title: s.t.colUid,
          width: const TableConstraint.length(6),
          cellBuilder: (u, c) => _cell('${u.uid}', c),
        ),
        TableColumn(
          title: s.t.colAdmin,
          width: const TableConstraint.length(6),
          cellBuilder: (u, c) => _cell(
            u.isAdmin(s.adminGroup) ? s.t.adminYes : '-',
            c,
            style: Style(fg: u.isAdmin(s.adminGroup) ? Color.yellow : null),
          ),
        ),
        TableColumn(
          title: s.t.colState,
          width: const TableConstraint.length(11),
          cellBuilder: (u, c) => switch (u.locked) {
            true => _cell(s.t.locked, c, style: const Style(fg: Color.red)),
            false => _cell(s.t.active, c, style: const Style(fg: Color.green)),
            null => _cell('?', c, style: const Style(dim: true)),
          },
        ),
        TableColumn(
          title: s.t.colShell,
          width: const TableConstraint.fill(2),
          cellBuilder: (u, c) => _cell(u.shell, c),
        ),
        TableColumn(
          title: s.t.colGroups,
          width: const TableConstraint.fill(3),
          cellBuilder: (u, c) =>
              _cell(u.groups.join(', '), c, style: const Style(dim: true)),
        ),
      ],
    ),
    s.usersTable,
    s.users.length,
    area,
  );
}

// ─── Processus ─────────────────────────────────────────────────────────────

List<TableColumn<Proc>> processColumns(VigieState s, {bool highlight = true}) {
  Color? heat(double v) =>
      v >= 50 ? Color.red : (v >= 15 ? Color.yellow : null);
  return [
    TableColumn(
      title: s.t.colPid,
      width: const TableConstraint.length(7),
      headerAlign: TextAlign.right,
      cellBuilder: (p, c) =>
          _cell('${p.pid}'.padLeft(7), c, highlight: highlight),
    ),
    TableColumn(
      title: s.t.colUser,
      width: const TableConstraint.length(12),
      cellBuilder: (p, c) =>
          _cell(p.user, c, style: const Style(dim: true), highlight: highlight),
    ),
    TableColumn(
      title: s.t.colCpu,
      width: const TableConstraint.length(6),
      headerAlign: TextAlign.right,
      cellBuilder: (p, c) => _cell(
        p.cpu.toStringAsFixed(1).padLeft(6),
        c,
        highlight: highlight,
        style: Style(fg: heat(p.cpu)),
      ),
    ),
    TableColumn(
      title: s.t.colRam,
      width: const TableConstraint.length(6),
      headerAlign: TextAlign.right,
      cellBuilder: (p, c) => _cell(
        p.mem.toStringAsFixed(1).padLeft(6),
        c,
        highlight: highlight,
        style: Style(fg: heat(p.mem)),
      ),
    ),
    TableColumn(
      title: s.t.colMemory,
      width: const TableConstraint.length(9),
      headerAlign: TextAlign.right,
      cellBuilder: (p, c) =>
          _cell(formatKb(p.rssKb, s.t).padLeft(9), c, highlight: highlight),
    ),
    TableColumn(
      title: s.t.colCommand,
      width: const TableConstraint.fill(1),
      cellBuilder: (p, c) => _cell(
        p.command,
        c,
        style: const Style(bold: true),
        highlight: highlight,
      ),
    ),
  ];
}

void renderProcesses(RenderContext ctx, VigieState s, Rect area) {
  _frame<Proc>(
    ctx,
    s,
    s.t.processesTitle(s.processes.length),
    Table<Proc>(
      id: Key.symbol(#processes),
      items: s.processes,
      state: s.processesTable,
      columnSeparator: ' │ ',
      placeholder: s.t.noProcesses,
      columns: processColumns(s),
    ),
    s.processesTable,
    s.processes.length,
    area,
  );
}

void renderTopProcesses(RenderContext ctx, VigieState s, Rect area) {
  final inner = Rect(area.x + 2, area.y + 1, area.width - 4, area.height - 2);

  ctx.draw(
    Container(border: BorderStyle.single, title: s.t.topProcesses),
    area,
  );
  if (inner.height <= 2) return;
  s.topProcessesTable.verticalScroll = 0;
  s.topProcessesTable.activeRow = -1;
  s.topProcessesTable.activeColumn = -1;
  ctx.draw(
    Table<Proc>(
      id: Key.symbol(#topProcesses),
      items: s.processes.take(inner.height - 1).toList(),
      state: s.topProcessesTable,
      columnSeparator: ' │ ',
      placeholder: s.t.noProcesses,
      columns: processColumns(s, highlight: false),
    ),
    inner,
  );
}
// ─── Services ──────────────────────────────────────────────────────────────

void renderServices(RenderContext ctx, VigieState s, Rect area) {
  Color? stateColor(Service svc) =>
      svc.isFailed ? Color.red : (svc.isRunning ? Color.green : null);

  _frame<Service>(
    ctx,
    s,
    s.t.servicesTableTitle(s.services.length),
    Table<Service>(
      id: Key.symbol(#services),
      items: s.services,
      state: s.servicesTable,
      columnSeparator: ' │ ',
      placeholder: s.t.noServices,
      columns: [
        TableColumn(
          title: '',
          width: const TableConstraint.length(1),
          cellBuilder: (svc, c) =>
              _cell('●', c, style: Style(fg: stateColor(svc) ?? Color.white)),
        ),
        TableColumn(
          title: s.t.colService,
          width: const TableConstraint.fill(2),
          cellBuilder: (svc, c) =>
              _cell(svc.name, c, style: const Style(bold: true)),
        ),
        TableColumn(
          title: s.t.colState,
          width: const TableConstraint.length(18),
          cellBuilder: (svc, c) => _cell(
            '${svc.active} (${svc.sub})',
            c,
            style: Style(fg: stateColor(svc), dim: stateColor(svc) == null),
          ),
        ),
        TableColumn(
          title: s.t.colBoot,
          width: const TableConstraint.length(9),
          cellBuilder: (svc, c) => _cell(
            svc.enabled,
            c,
            style: Style(
              fg: svc.enabled == 'enabled' ? Color.cyan : null,
              dim: svc.enabled != 'enabled',
            ),
          ),
        ),
        TableColumn(
          title: s.t.colDescription,
          width: const TableConstraint.fill(3),
          cellBuilder: (svc, c) =>
              _cell(svc.description, c, style: const Style(dim: true)),
        ),
      ],
    ),
    s.servicesTable,
    s.services.length,
    area,
  );
}
