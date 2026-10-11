import 'package:test/test.dart';
import 'package:vigie/src/system/overview.dart';

const sortiCat = '''
MemTotal:       24021688 kB
MemFree:         1004212 kB
MemAvailable:   15662808 kB
Buffers:          164632 kB
Cached:         17928896 kB
SwapCached:            0 kB
Active:          8358464 kB
Inactive:       13005188 kB
Active(anon):    7493444 kB
Inactive(anon):     3524 kB
Active(file):     865020 kB
Inactive(file): 13001664 kB
Unevictable:       10324 kB
Mlocked:            9376 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Zswap:                 0 kB
Zswapped:              0 kB
Dirty:               596 kB
''';

void main() {
  group('parseMemory', () {
    test('Check ram integrity (Total, free, pct)', () {
      final memory = parseMemory(sortiCat).first;
      expect(memory.name, 'RAM');
      expect(memory.total, 24021688);
      expect(memory.free, 15662808);
      expect(memory.memPct, closeTo(34.79, 0.01));
    });

    test('Check swap integrity (Total, free, pct)', () {
      final memory = parseMemory(sortiCat).last;
      expect(memory.name, 'SWAP');
      expect(memory.total, 0);
      expect(memory.free, 0);
      expect(memory.memPct, 0);
    });

    test('Check text integrity', () {
      const strangeText = '''
MemTotal:       24021688 kB
MemFree:         1004212 kB
MemAvailable:   15662808 kB
Buffers:          164632 kB
Cached:         17928896 kB
SwapCached:            0 kB
Active:          8358464 kB
Inactive:       13005188 kB
Active(anon):    7493444 kB
Inactive(anon):     3524 kB
Active(file):     865020 kB
Inactive(file): 13001664 kB
Unevictable:       10324 kB
Mlocked:            9376 kB
Zswap:                 0 kB
Zswapped:              0 kB
Dirty:               596 kB
''';
      expect(parseMemory(strangeText).last.total, 0);
      expect(parseMemory(strangeText).last.free, 0);
    });
  });
}
