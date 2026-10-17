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

final _virtualIfaces = RegExp(r'^(lo|docker|br-|veth|virbr|tun|wg)');
final _wholeDisk = RegExp(
  r'^(sd[a-z]+|vd[a-z]+|xvd[a-z]+|nvme\d+n\d+|mmcblk\d+)$',
);
final _sectorSize = 512;
const _diskInterval = Duration(seconds: 30);

/// Parses a text from /proc/stat into a map keyed by CPU name (cpu for the whole machine, cpu0, cpu1... for each one).
///
/// Expect lines like:
/// ```
/// cpu  2627260 15530 3606508 683539755 17686 0 150147 48289 0 0
/// ```
/// Return `name -> (idle, sum)`.
/// Both values (idle, sum) are cumulative counters since boot, in ticks: idle is the time spent (idle + iowait), sum is the total of all columns.
/// Line with fewer than 5 fields are skipped.

Map<String, (int, int)> parseCpu(String text) {
  final cpu = <String, (int, int)>{};

  for (final line in text.split('\n')) {
    if (!line.startsWith('cpu')) break;
    final parts = line.split(RegExp(r'\s+'));
    final name = parts.first;

    final v = parts.map(int.tryParse).skip(1).whereType<int>().toList();
    if (v.length < 5) continue;
    final idle = v[3] + v[4];
    final sum = v.fold<int>(0, (a, b) => a + b);

    cpu[name] = (idle, sum);
  }
  return cpu;
}

double cpuUsagePercent(int dIdle, int dTotal) =>
    dTotal <= 0 ? 0 : (1 - dIdle / dTotal) * 100;

class CpuSampler {
  /// Dernières valeurs mesurées, en %.
  double total = 0;
  List<double> cores = [];

  final historyTotal = History();
  final _lastIdle = <String, int>{};
  final _lastTotal = <String, int>{};

  void sample() {
    final newCores = <double>[];
    final lines = readFile('/proc/stat');

    final cpu = parseCpu(lines);
    for (final MapEntry(key: name, value: (idle, sum)) in cpu.entries) {
      final usage = _usage(name, idle, sum);
      if (name == 'cpu') {
        total = usage;
      } else {
        newCores.add(usage);
      }
    }
    cores = newCores;
    historyTotal.push(total);
  }

  double _usage(String name, int idle, int sum) {
    final dIdle = idle - (_lastIdle[name] ?? idle);
    final dTotal = sum - (_lastTotal[name] ?? sum);
    _lastIdle[name] = idle;
    _lastTotal[name] = sum;

    return cpuUsagePercent(dIdle, dTotal);
  }
}

class Disk {
  final String name;
  final int usage;
  final int freeSpace;

  Disk(this.name, this.usage, this.freeSpace);

  double get capacity => usage == 0 ? 0 : usage / (usage + freeSpace) * 100;
}

List<Disk>? _lastDiskList;
DateTime? _lastHourLecture;

List<Disk> parseDisks(String text) {
  final disks = <Disk>[];
  final seenDevices = <String>{};

  for (final line in text.split('\n').skip(1)) {
    final cols = line.trim().split(RegExp(r'\s+'));
    if (cols.length < 5) continue;
    if (!cols[0].startsWith('/dev/') || cols[0].startsWith('/dev/loop'))
      continue;
    if (!seenDevices.add(cols[0])) continue;

    final name = cols[0].split('/').last;

    disks.add(
      Disk(name, int.tryParse(cols[2]) ?? 0, int.tryParse(cols[3]) ?? 0),
    );
  }

  return disks;
}

(int, int) parseDiskStats(String text) {
  int read = 0;
  int write = 0;

  for (final line in text.split('\n')) {
    final cols = line.trim().split(RegExp(r'\s+'));
    if (cols.length < 10) continue;
    final name = cols[2];
    if (!_wholeDisk.hasMatch(name)) continue;

    read += (int.tryParse(cols[5]) ?? 0) * _sectorSize;
    write += (int.tryParse(cols[9]) ?? 0) * _sectorSize;
  }
  return (read, write);
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

  return parseDisks(diskList);
}

class Memory {
  final String name;
  final int total;
  final int free;

  Memory(this.name, this.total, this.free);

  int get used => total - free;
  double get memPct => total == 0 ? 0 : used / total * 100;
}

List<Memory> parseMemory(String text) {
  final total = _meminfo(text, 'MemTotal');
  final available = _meminfo(text, 'MemAvailable');
  final swapTotal = _meminfo(text, 'SwapTotal');
  final swapFree = _meminfo(text, 'SwapFree');

  final memory = <Memory>[
    Memory("RAM", total, available),
    Memory("SWAP", swapTotal, swapFree),
  ];

  return memory;
}

List<Memory> getMemory() {
  // Reading the memory for memory panels
  final mem = readFile('/proc/meminfo');
  return parseMemory(mem);
}

(int, int) parseNetwork(String text) {
  int totalReceived = 0;
  int totalSent = 0;

  for (final line in text.split('\n').skip(2)) {
    final lineCut = line.split(':');
    if (lineCut.length < 2) continue;
    final name = lineCut[0].trim();
    if (_virtualIfaces.hasMatch(name)) continue;
    final facesReceived = lineCut[1].trim().split(RegExp(r'\s+'));
    if (facesReceived.length < 9) continue;

    totalReceived += int.tryParse(facesReceived[0]) ?? 0;
    totalSent += int.tryParse(facesReceived[8]) ?? 0;
  }
  return (totalReceived, totalSent);
}

class History {
  final int max;
  final values = <double>[];

  History({this.max = 90});

  void push(double value) {
    values.add(value);
    if (values.length > max) values.removeAt(0);
  }
}

class RateSampler {
  final String path;
  final (int, int) Function(String) parse;

  RateSampler(this.path, this.parse);

  int? _lastTotalIn;
  int? _lastTotalOut;
  DateTime? _lastTime;
  double rateIn = 0;
  double rateOut = 0;

  final historyIn = History();
  final historyOut = History();

  void sample() {
    final text = readFile(path);
    final now = DateTime.now();

    final (totalIn, totalOut) = parse(text);

    final lastTotalIn = _lastTotalIn;
    final lastSentOut = _lastTotalOut;
    final lastTime = _lastTime;

    if (lastTotalIn != null && lastSentOut != null && lastTime != null) {
      final seconds = now.difference(lastTime).inMilliseconds / 1000;

      if (seconds > 0) {
        final gapIn = totalIn - lastTotalIn;
        final gapOut = totalOut - lastSentOut;

        if (gapIn >= 0) rateIn = gapIn / seconds;
        if (gapOut >= 0) rateOut = gapOut / seconds;
        historyIn.push(rateIn);
        historyOut.push(rateOut);
      }
    }

    _lastTotalIn = totalIn;
    _lastTotalOut = totalOut;
    _lastTime = now;
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
  try {
    final ifaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final iface in ifaces) {
      if (_virtualIfaces.hasMatch(iface.name)) continue;
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
  } catch (_) {}
  return '-';
}

String? _kernel;
String? _osNameValue;

Future<Overview> loadOverview(
  CpuSampler cpu,
  RateSampler net,
  RateSampler diskIo,
) async {
  cpu.sample();
  net.sample();
  diskIo.sample();
  final currentTime = DateTime.now();

  _kernel ??= (await capture('uname', ['-r'])).trim();
  _osNameValue ??= _osName();

  final upSeconds =
      double.tryParse(readFile('/proc/uptime').split(' ').first) ?? 0;

  if (_lastHourLecture == null ||
      currentTime.difference(_lastHourLecture!) > _diskInterval) {
    _lastDiskList = await getDisks();
    _lastHourLecture = currentTime;
  }

  return Overview(
    hostname: Platform.localHostname,
    os: _osNameValue!,
    kernel: _kernel!,
    uptime: Duration(seconds: upSeconds.round()),
    load: readFile('/proc/loadavg').split(' ').take(3).join('  '),
    memory: getMemory(),
    disk: _lastDiskList!,
    ip: await _mainIp(),
  );
}
