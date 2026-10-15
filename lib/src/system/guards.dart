enum RefusalReason { selfTarget, sshLockout, rootTarget, initTarget, vigieTarget }
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

RefusalReason? checkUserTarget(Map<String, String> env, String user, int uid, UserAction action) {
  if (uid == rootUid && UserAction.delete == action) return RefusalReason.rootTarget;
  if (env['SUDO_USER'] == user) return RefusalReason.selfTarget;
  return null;
}

RefusalReason? checkProcessTarget(int targetPid, int vigiePid) {
  if (targetPid == systemdPid) return RefusalReason.initTarget;
  if (targetPid == vigiePid) return RefusalReason.vigieTarget;
  return null;
}