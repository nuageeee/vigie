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
    required this.ip,
  });

  double get memPercent => memTotalKb == 0 ? 0 : memUsedKb / memTotalKb * 100;
  double get diskPercent =>
      diskTotalKb == 0 ? 0 : diskUsedKb / diskTotalKb * 100;
}

class CpuSampler {
  int _lastIdle = 0;
  int _lastTotal = 0;

  double sample() {
    final first = readFile('/proc/stat').split('\n').first;
    final v = first
        .split(RegExp(r'\s+'))
        .skip(1)
        .map(int.tryParse)
        .whereType<int>()
        .toList();
    if (v.length < 5) return 0;
    final idle = v[3] + v[4]; // idle + iowait
    final total = v.fold<int>(0, (a, b) => a + b);
    final dIdle = idle - _lastIdle;
    final dTotal = total - _lastTotal;
    _lastIdle = idle;
    _lastTotal = total;
    if (dTotal <= 0) return 0;
    return (1 - dIdle / dTotal) * 100;
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

Future<Overview> loadOverview(CpuSampler cpu) async {
  final mem = readFile('/proc/meminfo');
  final total = _meminfo(mem, 'MemTotal');
  final available = _meminfo(mem, 'MemAvailable');

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
    cpuUsage: cpu.sample(),
    memTotalKb: total,
    memUsedKb: total - available,
    diskTotalKb: disk.length > 2 ? int.tryParse(disk[1]) ?? 0 : 0,
    diskUsedKb: disk.length > 2 ? int.tryParse(disk[2]) ?? 0 : 0,
    ip: await _mainIp(),
  );
}

String formatUptime(Duration d) {
  final days = d.inDays;
  final h = d.inHours % 24;
  final m = d.inMinutes % 60;
  return days > 0 ? '${days}j ${h}h ${m}min' : '${h}h ${m}min';
}
