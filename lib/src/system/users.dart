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
