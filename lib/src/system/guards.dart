enum RefusalReason { selfTarget, sshLockout, rootTarget, initTarget, vigieTarget, lastAdmin }
enum UserAction { lock, delete, revokeAdmin }


final _sshService = RegExp(r'^(ssh|sshd)(\.service|\.socket)?$');
final _sshProcess = RegExp(r'^(sshd|sshd-session)$');
const rootUid = 0;
const systemdPid = 1;

bool hasSshAncestor(List<String> ancestors) =>
    ancestors.any((name) => _sshProcess.hasMatch(name));

RefusalReason? checkServiceTarget(Map<String, String> env, String service, List<String> ancestors) {
  final inSsh = env['SSH_CONNECTION'] != null || hasSshAncestor(ancestors);
  final targetSsh = _sshService.hasMatch(service);
  if (inSsh && targetSsh) return RefusalReason.sshLockout;
  return null;
}

RefusalReason? checkUserTarget({required Map<String, String> env, required String user, required int uid, required UserAction action, required bool isAdmin, required int adminNumber}) {
  if (uid == rootUid && UserAction.delete == action) return RefusalReason.rootTarget;
  if (isAdmin && adminNumber <= 1) return RefusalReason.lastAdmin;
  if (env['SUDO_USER'] == user) return RefusalReason.selfTarget;
  return null;
}

RefusalReason? checkProcessTarget(int targetPid, int vigiePid) {
  if (targetPid == systemdPid) return RefusalReason.initTarget;
  if (targetPid == vigiePid) return RefusalReason.vigieTarget;
  return null;
}