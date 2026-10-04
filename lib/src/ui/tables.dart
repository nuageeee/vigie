import 'package:commander_ui/tui.dart';

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
    'Utilisateurs (${s.users.length})',
    Table<SysUser>(
      id: Key.symbol(#users),
      items: s.users,
      state: s.usersTable,
      columnSeparator: ' │ ',
      placeholder: 'Aucun utilisateur',
      columns: [
        TableColumn(
          title: 'Nom',
          width: const TableConstraint.fill(2),
          cellBuilder: (u, c) =>
              _cell(u.name, c, style: const Style(bold: true)),
        ),
        TableColumn(
          title: 'UID',
          width: const TableConstraint.length(6),
          cellBuilder: (u, c) => _cell('${u.uid}', c),
        ),
        TableColumn(
          title: 'Admin',
          width: const TableConstraint.length(6),
          cellBuilder: (u, c) => _cell(
            u.isAdmin(s.AdminGroup) ? 'oui' : '-',
            c,
            style: Style(fg: u.isAdmin(s.AdminGroup) ? Color.yellow : null),
          ),
        ),
        TableColumn(
          title: 'État',
          width: const TableConstraint.length(11),
          cellBuilder: (u, c) => switch (u.locked) {
            true => _cell('verrouillé', c, style: const Style(fg: Color.red)),
            false => _cell('actif', c, style: const Style(fg: Color.green)),
            null => _cell('?', c, style: const Style(dim: true)),
          },
        ),
        TableColumn(
          title: 'Shell',
          width: const TableConstraint.fill(2),
          cellBuilder: (u, c) => _cell(u.shell, c),
        ),
        TableColumn(
          title: 'Groupes',
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
    'Processus (${s.processes.length}) · triés par CPU',
    Table<Proc>(
      id: Key.symbol(#processes),
      items: s.processes,
      state: s.processesTable,
      columnSeparator: ' │ ',
      placeholder: 'Aucun processus',
      columns: [
        TableColumn(
          title: 'PID',
          width: const TableConstraint.length(7),
          headerAlign: TextAlign.right,
          cellBuilder: (p, c) => _cell('${p.pid}'.padLeft(7), c),
        ),
        TableColumn(
          title: 'Utilisateur',
          width: const TableConstraint.length(12),
          cellBuilder: (p, c) =>
              _cell(p.user, c, style: const Style(dim: true)),
        ),
        TableColumn(
          title: 'CPU %',
          width: const TableConstraint.length(6),
          headerAlign: TextAlign.right,
          cellBuilder: (p, c) => _cell(
            p.cpu.toStringAsFixed(1).padLeft(6),
            c,
            style: Style(fg: heat(p.cpu)),
          ),
        ),
        TableColumn(
          title: 'RAM %',
          width: const TableConstraint.length(6),
          headerAlign: TextAlign.right,
          cellBuilder: (p, c) => _cell(
            p.mem.toStringAsFixed(1).padLeft(6),
            c,
            style: Style(fg: heat(p.mem)),
          ),
        ),
        TableColumn(
          title: 'Mémoire',
          width: const TableConstraint.length(9),
          headerAlign: TextAlign.right,
          cellBuilder: (p, c) => _cell(formatKb(p.rssKb).padLeft(9), c),
        ),
        TableColumn(
          title: 'Commande',
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
    'Services systemd (${s.services.length})',
    Table<Service>(
      id: Key.symbol(#services),
      items: s.services,
      state: s.servicesTable,
      columnSeparator: ' │ ',
      placeholder: 'Aucun service (systemd absent ?)',
      columns: [
        TableColumn(
          title: '',
          width: const TableConstraint.length(1),
          cellBuilder: (svc, c) =>
              _cell('●', c, style: Style(fg: stateColor(svc) ?? Color.white)),
        ),
        TableColumn(
          title: 'Service',
          width: const TableConstraint.fill(2),
          cellBuilder: (svc, c) =>
              _cell(svc.name, c, style: const Style(bold: true)),
        ),
        TableColumn(
          title: 'État',
          width: const TableConstraint.length(18),
          cellBuilder: (svc, c) => _cell(
            '${svc.active} (${svc.sub})',
            c,
            style: Style(fg: stateColor(svc), dim: stateColor(svc) == null),
          ),
        ),
        TableColumn(
          title: 'Au boot',
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
          title: 'Description',
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
