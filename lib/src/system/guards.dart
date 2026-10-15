enum RefusalReason { selfTarget, sshLockout, rootTarget }

final _sshService = RegExp(r'^(ssh|sshd)(\.service|\.socket)?$');
final _sshProcess = RegExp(r'^(sshd|sshd-session)$');
const rootUid = 0;

bool hasSshAncestor(List<String> ancestors) =>
    ancestors.any((name) => _sshProcess.hasMatch(name));

RefusalReason? checkServiceTarget(Map<String, String> env, String service, List<String> ancestors) {
  final inSsh = env['SSH_CONNECTION'] != null || hasSshAncestor(ancestors);
  final targetSsh = _sshService.hasMatch(service);
  if (inSsh && targetSsh) return RefusalReason.sshLockout;
  return null;
}

RefusalReason? checkUserTarget(Map<String, String> env, String user, int uid, String action) {
  if (uid == rootUid && action == 'delete') return RefusalReason.rootTarget;
  if (env['SUDO_USER'] == user) return RefusalReason.selfTarget;
  return null;
}