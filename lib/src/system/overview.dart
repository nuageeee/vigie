import 'dart:async';
import 'dart:io';

import 'shell.dart';

class Overview {
  final String hostname;
  final String os;
  final String kernel;
  final Duration uptime;
  final String load;
  final double cpuUsage;
  final int memTotalKb;
  final int memUsedKb;
  final int diskTotalKb;
  final int diskUsedKb;
  final List<Disk> disk;
  final String ip;

  const Overview({
    required this.hostname,
    required this.os,
    required this.kernel,
    required this.uptime,
    required this.load,
    required this.cpuUsage,
    required this.memTotalKb,
    required this.memUsedKb,
    required this.diskTotalKb,
    required this.diskUsedKb,
    required this.disk,
    required this.ip,
  });

  double get memPercent => memTotalKb == 0 ? 0 : memUsedKb / memTotalKb * 100;
  double get diskPercent =>
      diskTotalKb == 0 ? 0 : diskUsedKb / diskTotalKb * 100;
}

class CpuSampler {
  /// Dernières valeurs mesurées, en %.
  double total = 0;
  List<double> cores = [];

  final _lastIdle = <String, int>{};
  final _lastTotal = <String, int>{};

  int compteur = 0;

  void sample() {
    compteur++;
    final newCores = <double>[];

    for (final line in readFile('/proc/stat').split('\n')) {
      if (!line.startsWith('cpu')) break;
      final parts = line.split(RegExp(r'\s+'));
      final name = parts.first;
      final usage = _usage(name, parts.skip(1));

      if (name == 'cpu') {
        total = usage;
      } else {
        newCores.add(usage);
      }
    }
    cores = newCores;
  }

  double _usage(String name, Iterable<String> fields) {
    final v = fields.map(int.tryParse).whereType<int>().toList();
    if (v.length < 5) return 0;

    final idle = v[3] + v[4]; // idle + iowait
    final sum = v.fold<int>(0, (a, b) => a + b);
    final dIdle = idle - (_lastIdle[name] ?? idle);
    final dTotal = sum - (_lastTotal[name] ?? sum);
    _lastIdle[name] = idle;
    _lastTotal[name] = sum;

    return dTotal <= 0 ? 0 : (1 - dIdle / dTotal) * 100;
  }
}

class Disk {
  final String name;
  final int usage;
  final int freeSpace;

  Disk(this.name, this.usage, this.freeSpace);

  double get Capacity => usage / (usage + freeSpace) * 100;
}

Future<List<Disk>> getDisks() async {
  final diskList = await capture('df', [
    '-P',
    '-k',
    '-x',
    'tmpfs',
    '-x',
    'devtmpfs',
    '-x',
    'overlay',
    '-x',
    'squashfs',
  ]);

  final disks = <Disk>[];

  for (final line in diskList.split('\n').skip(1)) {
    final cols = line.trim().split(RegExp(r'\s+'));
    if (cols.length < 3) continue;

    final name = cols[0].split('/').last;

    disks.add(Disk(name, int.parse(cols[2]), int.parse(cols[3])));
  }

  return disks;
}

String _osName() {
  final m = RegExp(
    r'^PRETTY_NAME="?([^"\n]*)"?',
    multiLine: true,
  ).firstMatch(readFile('/etc/os-release'));
  return m?.group(1) ?? 'Linux';
}

int _meminfo(String text, String key) {
  final m = RegExp('^$key:\\s+(\\d+)', multiLine: true).firstMatch(text);
  return int.tryParse(m?.group(1) ?? '') ?? 0;
}

Future<String> _mainIp() async {
  final virtual = RegExp(r'^(lo|docker|br-|veth|virbr|tun|wg)');
  try {
    final ifaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final iface in ifaces) {
      if (virtual.hasMatch(iface.name)) continue;
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
  } catch (_) {}
  return '-';
}

Future<Overview> loadOverview(CpuSampler cpu) async {
  final mem = readFile('/proc/meminfo');
  final total = _meminfo(mem, 'MemTotal');
  final available = _meminfo(mem, 'MemAvailable');
  cpu.sample();

  final df = (await capture('df', ['-Pk', '/'])).split('\n');
  final disk = df.length > 1 ? splitColumns(df[1], 6) : const <String>[];

  final upSeconds =
      double.tryParse(readFile('/proc/uptime').split(' ').first) ?? 0;

  return Overview(
    hostname: Platform.localHostname,
    os: _osName(),
    kernel: (await capture('uname', ['-r'])).trim(),
    uptime: Duration(seconds: upSeconds.round()),
    load: readFile('/proc/loadavg').split(' ').take(3).join('  '),
    cpuUsage: cpu.total,
    memTotalKb: total,
    memUsedKb: total - available,
    diskTotalKb: disk.length > 2 ? int.tryParse(disk[1]) ?? 0 : 0,
    diskUsedKb: disk.length > 2 ? int.tryParse(disk[2]) ?? 0 : 0,
    disk: (await getDisks()),
    ip: await _mainIp(),
  );
}

String formatUptime(Duration d) {
  final days = d.inDays;
  final h = d.inHours % 24;
  final m = d.inMinutes % 60;
  return days > 0 ? '${days}j ${h}h ${m}min' : '${h}h ${m}min';
}
