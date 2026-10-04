import 'shell.dart';

class SysUser {
  final String name;
  final int uid;
  final String home;
  final String shell;
  final List<String> groups;
  final bool? locked; // null = inconnu (pas les droits pour lire /etc/shadow)

  const SysUser(
    this.name,
    this.uid,
    this.home,
    this.shell,
    this.groups,
    this.locked,
  );

  bool isAdmin(String adminGroup) => uid == 0 || groups.contains(adminGroup);
}

/// Groupe qui donne les droits sudo : `sudo` (Debian/Ubuntu) ou `wheel` (Arch, Fedora).
String detectAdminGroup() {
  final groups = readFile('/etc/group');
  return RegExp(r'^sudo:', multiLine: true).hasMatch(groups) ? 'sudo' : 'wheel';
}

final usernamePattern = RegExp(r'^[a-z_][a-z0-9_-]{0,31}$');

Future<List<SysUser>> LoadUsers() async {
  final shadow = readFile('/etc/shadow');
  final lockedByName = <String, bool>{};
  for (final line in shadow.split('\n')) {
    final p = line.split(':');
    if (p.length > 1) lockedByName[p[0]] = p[1].startsWith('!');
  }

  final groupsByUser = <String, List<String>>{};
  final primaryGroupByGid = <String, String>{};
  for (final line in readFile('/etc/group').split('\n')) {
    final p = line.split(':');
    if (p.length < 4) continue;
    primaryGroupByGid[p[2]] = p[0];
    for (final member in p[3].split(',')) {
      if (member.isNotEmpty) (groupsByUser[member] ??= []).add(p[0]);
    }
  }

  final list = <SysUser>[];
  for (final line in readFile('/etc/passwd').split('\n')) {
    final p = line.split(':');
    if (p.length < 7) continue;
    final uid = int.tryParse(p[2]) ?? -1;
    if (!(uid == 0 || (uid >= 1000 && uid < 65534))) continue;
    final primary = primaryGroupByGid[p[3]];
    final groups = [if (primary != null) primary, ...?groupsByUser[p[0]]];
    list.add(
      SysUser(
        p[0],
        uid,
        p[5],
        p[6],
        groups,
        shadow.isEmpty ? null : lockedByName[p[0]],
      ),
    );
  }
  list.sort((a, b) => a.uid.compareTo(b.uid));
  return list;
}

Future<CmdResult> addUser(String name) => run('useradd', [
  '-m',
  '-s',
  '/bin/bash',
  name,
], success: 'Utilisateur $name créé (pense à lui donner un mot de passe : p)');

Future<CmdResult> deleteUser(SysUser u) =>
    run('userdel', ['-r', u.name], success: 'Utilisateur ${u.name} supprimé');

Future<CmdResult> setPassword(SysUser u, String password) => run(
  'chpasswd',
  [],
  stdinData: '${u.name}:$password\n',
  success: 'Mot de passe de ${u.name} modifié',
);

Future<CmdResult> toggleLock(SysUser u) => u.locked == true
    ? run('usermod', ['-U', u.name], success: '${u.name} déverrouillé')
    : run('usermod', ['-L', u.name], success: '${u.name} verrouillé');

Future<CmdResult> toggleAdmin(SysUser u, String adminGroup) =>
    u.groups.contains(adminGroup)
    ? run('gpasswd', [
        '-d',
        u.name,
        adminGroup,
      ], success: '${u.name} retiré du groupe $adminGroup')
    : run('gpasswd', [
        '-a',
        u.name,
        adminGroup,
      ], success: '${u.name} ajouté au groupe $adminGroup');
