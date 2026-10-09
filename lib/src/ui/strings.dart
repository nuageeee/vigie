import 'package:vigie/src/state.dart';

/// Textes de l'interface, une instance par langue (voir [stringsFor]).
class Strings {
  // ─── Démarrage et barre d'état ─────────────────────────────────────────────
  final String notLinux;
  final String readOnly;
  final String ready;
  final String cancelled;
  final String refreshing;
  final String rootRequired;
  final String loading;

  // ─── Onglets ───────────────────────────────────────────────────────────────
  final String sectionDashboard;
  final String sectionUsers;
  final String sectionProcesses;
  final String sectionServices;

  // ─── Confirmations ─────────────────────────────────────────────────────────
  final String yesKey;
  final String yes;
  final String noKey;
  final String no;
  final String Function(String name) askStart;
  final String Function(String name) askStop;
  final String Function(String name) askRestart;
  final String Function(String name) askEnable;
  final String Function(String name) askDisable;
  final String Function(String command, int pid) askTerm;
  final String Function(String command, int pid) askKill;
  final String Function(String name) askUnlock;
  final String Function(String name) askLock;
  final String Function(String group, String name) askRevokeAdmin;
  final String Function(String group, String name) askGrantAdmin;
  final String Function(String name, String home) askDeleteUser;
  final String cannotDeleteRoot;

  // ─── Saisies ───────────────────────────────────────────────────────────────
  final String newUserTitle;
  final String newUserLabel;
  final String usernameRule;
  final String Function(String name) passwordTitle;
  final String passwordLabel;
  final String passwordRule;
  final String promptHelp;

  // ─── Barre d'actions ───────────────────────────────────────────────────────
  final String btnAdd;
  final String btnPassword;
  final String btnLock;
  final String btnAdmin;
  final String btnDelete;
  final String btnTerm;
  final String btnKill;
  final String btnStart;
  final String btnStop;
  final String btnRestart;
  final String btnEnable;
  final String btnDisable;
  final String btnTerminal;
  final String btnRefresh;
  final String btnQuit;

  // ─── Panneau système ───────────────────────────────────────────────────────
  final String system;
  final String host;
  final String os;
  final String kernel;
  final String uptime;
  final String ip;

  // ─── Tableau de bord ───────────────────────────────────────────────────────
  final String Function(int cores, String pct) cpuTitle;
  final String Function(int count, String total) disksTitle;
  final String Function(String used, String total) memoryTitle;
  final String network;
  final String servicesTitle;
  final String Function(int running, int total) servicesRunning;
  final String Function(int count) servicesFailed;
  final String goToServices;

  // ─── Tableaux ──────────────────────────────────────────────────────────────
  final String Function(int count) usersTitle;
  final String noUsers;
  final String colName;
  final String colUid;
  final String colAdmin;
  final String colState;
  final String colShell;
  final String colGroups;
  final String adminYes;
  final String locked;
  final String active;

  final String Function(int count) processesTitle;
  final String noProcesses;
  final String colPid;
  final String colUser;
  final String colCpu;
  final String colRam;
  final String colMemory;
  final String colCommand;

  final String Function(int count) servicesTableTitle;
  final String noServices;
  final String colService;
  final String colBoot;
  final String colDescription;

  // ─── Unités ────────────────────────────────────────────────────────────────
  /// Octet, kilo, méga, giga.
  final List<String> byteUnits;
  final String dayUnit;

  const Strings({
    required this.notLinux,
    required this.readOnly,
    required this.ready,
    required this.cancelled,
    required this.refreshing,
    required this.rootRequired,
    required this.loading,
    required this.sectionDashboard,
    required this.sectionUsers,
    required this.sectionProcesses,
    required this.sectionServices,
    required this.yesKey,
    required this.yes,
    required this.noKey,
    required this.no,
    required this.askStart,
    required this.askStop,
    required this.askRestart,
    required this.askEnable,
    required this.askDisable,
    required this.askTerm,
    required this.askKill,
    required this.askUnlock,
    required this.askLock,
    required this.askRevokeAdmin,
    required this.askGrantAdmin,
    required this.askDeleteUser,
    required this.cannotDeleteRoot,
    required this.newUserTitle,
    required this.newUserLabel,
    required this.usernameRule,
    required this.passwordTitle,
    required this.passwordLabel,
    required this.passwordRule,
    required this.promptHelp,
    required this.btnAdd,
    required this.btnPassword,
    required this.btnLock,
    required this.btnAdmin,
    required this.btnDelete,
    required this.btnTerm,
    required this.btnKill,
    required this.btnStart,
    required this.btnStop,
    required this.btnRestart,
    required this.btnEnable,
    required this.btnDisable,
    required this.btnTerminal,
    required this.btnRefresh,
    required this.btnQuit,
    required this.system,
    required this.host,
    required this.os,
    required this.kernel,
    required this.uptime,
    required this.ip,
    required this.cpuTitle,
    required this.disksTitle,
    required this.memoryTitle,
    required this.network,
    required this.servicesTitle,
    required this.servicesRunning,
    required this.servicesFailed,
    required this.goToServices,
    required this.usersTitle,
    required this.noUsers,
    required this.colName,
    required this.colUid,
    required this.colAdmin,
    required this.colState,
    required this.colShell,
    required this.colGroups,
    required this.adminYes,
    required this.locked,
    required this.active,
    required this.processesTitle,
    required this.noProcesses,
    required this.colPid,
    required this.colUser,
    required this.colCpu,
    required this.colRam,
    required this.colMemory,
    required this.colCommand,
    required this.servicesTableTitle,
    required this.noServices,
    required this.colService,
    required this.colBoot,
    required this.colDescription,
    required this.byteUnits,
    required this.dayUnit,
  });

  String sectionLabel(Section section) => switch (section) {
    Section.table => sectionDashboard,
    Section.users => sectionUsers,
    Section.process => sectionProcesses,
    Section.services => sectionServices,
  };
}

final fr = Strings(
  notLinux: 'Vigie ne fonctionne que sous Linux.',
  readOnly: 'Mode lecture seule : lance "sudo vigie" pour agir sur le système',
  ready: 'Prêt',
  cancelled: 'Annulé',
  refreshing: 'Rafraîchissement...',
  rootRequired: 'Action impossible : relance Vigie avec sudo',
  loading: ' Chargement...',
  sectionDashboard: 'Aperçu',
  sectionUsers: 'Utilisateurs',
  sectionProcesses: 'Processus',
  sectionServices: 'Services',
  yesKey: 'o',
  yes: 'Oui',
  noKey: 'n',
  no: 'Non',
  askStart: (n) => 'Démarrer $n ?',
  askStop: (n) => 'Arrêter $n ?',
  askRestart: (n) => 'Redémarrer $n ?',
  askEnable: (n) => 'Activer $n au démarrage ?',
  askDisable: (n) => 'Désactiver $n au démarrage ?',
  askTerm: (cmd, pid) => "Demander l'arrêt de $cmd (PID $pid) ?",
  askKill: (cmd, pid) => 'TUER $cmd (PID $pid) sans sommation ?',
  askUnlock: (n) => 'Déverrouiller $n ?',
  askLock: (n) => 'Verrouiller $n ?',
  askRevokeAdmin: (g, n) => 'Retirer les droits admin ($g) à $n ?',
  askGrantAdmin: (g, n) => 'Donner les droits admin ($g) à $n ?',
  askDeleteUser: (n, home) => 'SUPPRIMER $n et son dossier $home ?',
  cannotDeleteRoot: 'On ne supprime pas root 🙂',
  newUserTitle: ' Nouvel utilisateur ',
  newUserLabel: 'Nom',
  usernameRule: 'Minuscules, chiffres, - et _ uniquement (32 max)',
  passwordTitle: (n) => ' Mot de passe de $n ',
  passwordLabel: 'Nouveau mot de passe',
  passwordRule: '8 caractères minimum',
  promptHelp: ' Entrée valider · Échap annuler',
  btnAdd: 'ajouter',
  btnPassword: 'mot de passe',
  btnLock: 'verrouiller',
  btnAdmin: 'admin',
  btnDelete: 'supprimer',
  btnTerm: 'arrêter',
  btnKill: 'tuer',
  btnStart: 'démarrer',
  btnStop: 'arrêter',
  btnRestart: 'redémarrer',
  btnEnable: 'activer boot',
  btnDisable: 'désactiver boot',
  btnTerminal: 'terminal',
  btnRefresh: 'rafraîchir',
  btnQuit: 'quitter',
  system: 'Système',
  host: 'Hôte',
  os: 'OS',
  kernel: 'Noyau',
  uptime: 'Démarré depuis',
  ip: 'IP',
  cpuTitle: (n, pct) => 'CPU · $n cœurs · $pct%',
  disksTitle: (n, total) => 'Disques · $n · Total · $total',
  memoryTitle: (used, total) => 'Mémoires · Utilisé · $used · Total · $total',
  network: 'Réseaux',
  servicesTitle: ' Services ',
  servicesRunning: (r, t) => 'Services actifs : $r / $t',
  servicesFailed: (n) => 'Services en échec : $n',
  goToServices: '→ touche 4 pour aller les gérer',
  usersTitle: (n) => 'Utilisateurs ($n)',
  noUsers: 'Aucun utilisateur',
  colName: 'Nom',
  colUid: 'UID',
  colAdmin: 'Admin',
  colState: 'État',
  colShell: 'Shell',
  colGroups: 'Groupes',
  adminYes: 'oui',
  locked: 'verrouillé',
  active: 'actif',
  processesTitle: (n) => 'Processus ($n) · triés par CPU',
  noProcesses: 'Aucun processus',
  colPid: 'PID',
  colUser: 'Utilisateur',
  colCpu: 'CPU %',
  colRam: 'RAM %',
  colMemory: 'Mémoire',
  colCommand: 'Commande',
  servicesTableTitle: (n) => 'Services systemd ($n)',
  noServices: 'Aucun service (systemd absent ?)',
  colService: 'Service',
  colBoot: 'Au boot',
  colDescription: 'Description',
  byteUnits: const ['o', 'Ko', 'Mo', 'Go'],
  dayUnit: 'j',
);

final en = Strings(
  notLinux: 'Vigie only works on Linux.',
  readOnly: 'Read-only mode: run "sudo vigie" to act on the system',
  ready: 'Ready',
  cancelled: 'Cancelled',
  refreshing: 'Refreshing...',
  rootRequired: 'Action not allowed: restart Vigie with sudo',
  loading: ' Loading...',
  sectionDashboard: 'Dashboard',
  sectionUsers: 'Users',
  sectionProcesses: 'Processes',
  sectionServices: 'Services',
  yesKey: 'y',
  yes: 'Yes',
  noKey: 'n',
  no: 'No',
  askStart: (n) => 'Start $n?',
  askStop: (n) => 'Stop $n?',
  askRestart: (n) => 'Restart $n?',
  askEnable: (n) => 'Enable $n at boot?',
  askDisable: (n) => 'Disable $n at boot?',
  askTerm: (cmd, pid) => 'Ask $cmd (PID $pid) to terminate?',
  askKill: (cmd, pid) => 'KILL $cmd (PID $pid) without warning?',
  askUnlock: (n) => 'Unlock $n?',
  askLock: (n) => 'Lock $n?',
  askRevokeAdmin: (g, n) => 'Revoke admin rights ($g) from $n?',
  askGrantAdmin: (g, n) => 'Grant admin rights ($g) to $n?',
  askDeleteUser: (n, home) => 'DELETE $n and their home $home?',
  cannotDeleteRoot: "Root can't be deleted 🙂",
  newUserTitle: ' New user ',
  newUserLabel: 'Name',
  usernameRule: 'Lowercase, digits, - and _ only (32 max)',
  passwordTitle: (n) => ' Password for $n ',
  passwordLabel: 'New password',
  passwordRule: '8 characters minimum',
  promptHelp: ' Enter confirm · Esc cancel',
  btnAdd: 'add',
  btnPassword: 'password',
  btnLock: 'lock',
  btnAdmin: 'admin',
  btnDelete: 'delete',
  btnTerm: 'stop',
  btnKill: 'kill',
  btnStart: 'start',
  btnStop: 'stop',
  btnRestart: 'restart',
  btnEnable: 'enable boot',
  btnDisable: 'disable boot',
  btnTerminal: 'terminal',
  btnRefresh: 'refresh',
  btnQuit: 'quit',
  system: 'System',
  host: 'Host',
  os: 'OS',
  kernel: 'Kernel',
  uptime: 'Uptime',
  ip: 'IP',
  cpuTitle: (n, pct) => 'CPU · $n cores · $pct%',
  disksTitle: (n, total) => 'Disks · $n · Total · $total',
  memoryTitle: (used, total) => 'Memory · Used · $used · Total · $total',
  network: 'Network',
  servicesTitle: ' Services ',
  servicesRunning: (r, t) => 'Running services: $r / $t',
  servicesFailed: (n) => 'Failed services: $n',
  goToServices: '→ press 4 to manage them',
  usersTitle: (n) => 'Users ($n)',
  noUsers: 'No users',
  colName: 'Name',
  colUid: 'UID',
  colAdmin: 'Admin',
  colState: 'State',
  colShell: 'Shell',
  colGroups: 'Groups',
  adminYes: 'yes',
  locked: 'locked',
  active: 'active',
  processesTitle: (n) => 'Processes ($n) · sorted by CPU',
  noProcesses: 'No processes',
  colPid: 'PID',
  colUser: 'User',
  colCpu: 'CPU %',
  colRam: 'RAM %',
  colMemory: 'Memory',
  colCommand: 'Command',
  servicesTableTitle: (n) => 'systemd services ($n)',
  noServices: 'No services (is systemd missing?)',
  colService: 'Service',
  colBoot: 'On boot',
  colDescription: 'Description',
  byteUnits: const ['B', 'KB', 'MB', 'GB'],
  dayUnit: 'd',
);

/// Code de langue retenu pour une locale : 'fr' si elle commence par "fr",
/// sinon 'en'.
String langCode(String locale) =>
    locale.toLowerCase().startsWith('fr') ? 'fr' : 'en';

Strings stringsFor(String locale) => langCode(locale) == 'fr' ? fr : en;
