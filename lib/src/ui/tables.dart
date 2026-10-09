import 'package:commander_ui/tui.dart';
import 'package:vigie/src/ui/components/formators.dart';

import '../state.dart';
import '../system/processes.dart';
import '../system/services.dart';
import '../system/users.dart';

Widget _cell(String text, TableCellState c, {Style style = Style.none}) => Text(
  text,
  style: c.isRowActive && c.isFocused
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
            u.isAdmin(s.AdminGroup) ? s.t.adminYes : '-',
            c,
            style: Style(fg: u.isAdmin(s.AdminGroup) ? Color.yellow : null),
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

void renderProcesses(RenderContext ctx, VigieState s, Rect area) {
  Color? heat(double v) =>
      v >= 50 ? Color.red : (v >= 15 ? Color.yellow : null);

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
      columns: [
        TableColumn(
          title: s.t.colPid,
          width: const TableConstraint.length(7),
          headerAlign: TextAlign.right,
          cellBuilder: (p, c) => _cell('${p.pid}'.padLeft(7), c),
        ),
        TableColumn(
          title: s.t.colUser,
          width: const TableConstraint.length(12),
          cellBuilder: (p, c) =>
              _cell(p.user, c, style: const Style(dim: true)),
        ),
        TableColumn(
          title: s.t.colCpu,
          width: const TableConstraint.length(6),
          headerAlign: TextAlign.right,
          cellBuilder: (p, c) => _cell(
            p.cpu.toStringAsFixed(1).padLeft(6),
            c,
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
            style: Style(fg: heat(p.mem)),
          ),
        ),
        TableColumn(
          title: s.t.colMemory,
          width: const TableConstraint.length(9),
          headerAlign: TextAlign.right,
          cellBuilder: (p, c) => _cell(formatKb(p.rssKb).padLeft(9), c),
        ),
        TableColumn(
          title: s.t.colCommand,
          width: const TableConstraint.fill(1),
          cellBuilder: (p, c) =>
              _cell(p.command, c, style: const Style(bold: true)),
        ),
      ],
    ),
    s.processesTable,
    s.processes.length,
    area,
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
