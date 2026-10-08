import 'dart:async';
import 'dart:io';

import 'shell.dart';

class Overview {
  final String hostname;
  final String os;
  final String kernel;
  final Duration uptime;
  final String load;
  final List<Memory> memory;
  final List<Disk> disk;
  final String ip;

  const Overview({
    required this.hostname,
    required this.os,
    required this.kernel,
    required this.uptime,
    required this.load,
    required this.memory,
    required this.disk,
    required this.ip,
  });
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

  double get Capacity => usage == 0 ? 0 : usage / (usage + freeSpace) * 100;
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

class Memory {
  final String name;
  final int total;
  final int free;

  Memory(this.name, this.total, this.free);

  int get used => total - free;
  double get memPct => total == 0 ? 0 : used / total * 100;
}

List<Memory> getMemory() {
  // Reading the memory for memory panels
  final mem = readFile('/proc/meminfo');
  final total = _meminfo(mem, 'MemTotal');
  final available = _meminfo(mem, 'MemAvailable');
  final swapTotal = _meminfo(mem, 'SwapTotal');
  final swapFree = _meminfo(mem, 'SwapFree');

  final memory = <Memory>[
    Memory("RAM", total, available),
    Memory("SWAP", swapTotal, swapFree),
  ];

  return memory;
}

class Network {
  int? _lastReceived;
  int? _lastSent;
  DateTime? _lastHour;
  double received = 0;
  double sent = 0;

  final virtual = RegExp(r'^(lo|docker|br-|veth|virbr|tun|wg)');
  void sample() {
    int totalReceived = 0;
    int totalSent = 0;
    double seconds = 0;
    final netInt = readFile('/proc/net/dev');
    final now = DateTime.now();

    for (final line in netInt.split('\n').skip(2)) {
      final lineCut = line.split(':');
      if (lineCut.length < 2) continue;
      final name = lineCut[0].trim();
      if (virtual.hasMatch(name)) continue;
      final facesReceived = lineCut[1].trim().split(RegExp(r'\s+'));

      totalReceived += int.tryParse(facesReceived[0]) ?? 0;
      totalSent += int.tryParse(facesReceived[8]) ?? 0;
    }

    final lastReceived = _lastReceived;
    final lastSent = _lastSent;
    final lastHour = _lastHour;

    if (lastReceived != null && lastSent != null) {
      if (lastHour != null) {
        seconds = now.difference(lastHour).inMilliseconds / 1000;
      }

      if (seconds > 0) {
        final gapReceived = totalReceived - lastReceived;
        final gapSent = totalSent - lastSent;

        if (gapReceived >= 0) received = gapReceived / seconds;
        if (gapSent >= 0) sent = gapSent / seconds;
      }
    }

    _lastReceived = totalReceived;
    _lastSent = totalSent;
    _lastHour = now;
  }
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

Future<Overview> loadOverview(CpuSampler cpu, Network net) async {
  cpu.sample();
  net.sample();

  final upSeconds =
      double.tryParse(readFile('/proc/uptime').split(' ').first) ?? 0;

  return Overview(
    hostname: Platform.localHostname,
    os: _osName(),
    kernel: (await capture('uname', ['-r'])).trim(),
    uptime: Duration(seconds: upSeconds.round()),
    load: readFile('/proc/loadavg').split(' ').take(3).join('  '),
    memory: getMemory(),
    disk: await getDisks(),
    ip: await _mainIp(),
  );
}

String formatUptime(Duration d) {
  final days = d.inDays;
  final h = d.inHours % 24;
  final m = d.inMinutes % 60;
  return days > 0 ? '${days}j ${h}h ${m}min' : '${h}h ${m}min';
}
