import 'package:test/test.dart';
import 'package:vigie/src/system/overview.dart';

const catExit = '''
Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
    lo: 1260284938 3910690    0    0    0     0          0         0 1260284938 3910690    0    0    0     0       0          0
  ens3: 7506157897 4821952    0    0    0     0          0         0 1994284564 4738211    0    0    0     0       0          0
docker0:       0       0    0    0    0     0          0         0        0       0    0    2    0     0       0          0
docker_gwbridge: 620138282  939686    0    0    0     0          0         0 582572098  662242    0    1    0     0       0          0
vethe7ef6a6:     126       3    0    0    0     0          0         0    90241    1189    0    0    0     0       0          0
vethef6fbd7:     126       3    0    0    0     0          0         0    89605    1181    0    0    0     0       0          0
veth83d0530: 34608784   36818    0    0    0     0          0         0 24940323   35305    0    0    0     0       0          0
vethc17f3ed: 598684766  902860    0    0    0     0          0         0 557734644  628308    0    0    0     0       0          0
br-c6f16e7854e5: 49658492  470379    0    0    0     0          0        12 2231400175  526754    0    1    0     0       0          0
veth19aa0b7: 27715706  266705    0    0    0     0          0         0 75217423  273540    0    0    0     0       0          0
br-8c9b1dc4fdd3:     252       9    0    0    0     0          0         0     1020      10    0    1    0     0       0          0
veth51bc281:     126       3    0    0    0     0          0         0     9486     133    0    0    0     0       0          0
''';

void main() {
  group('parseNetwork', () {
    test('Sums only the physical ifaces', () {
      expect(parseNetwork(catExit), (7506157897, 1994284564));
    });
    test('ignores lines with too few columns', () {
      const strangeValue = '''
Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
    lo: 1260284938 3910690    0    0    0     0          0         0 1260284938 3910690    0    0    0     0       0          0
  ens3: 7506157897 4821952    0    0    0     0          0         0 1994284564 4738211    0    0    0     0       0          0
  eth0: 999 999 999 999
docker0:       0       0    0    0    0     0          0         0        0       0    0    2    0     0       0          0
docker_gwbridge: 620138282  939686    0    0    0     0          0         0 582572098  662242    0    1    0     0       0          0
vethe7ef6a6:     126       3    0    0    0     0          0         0    90241    1189    0    0    0     0       0          0
vethef6fbd7:     126       3    0    0    0     0          0         0    89605    1181    0    0    0     0       0          0
veth83d0530: 34608784   36818    0    0    0     0          0         0 24940323   35305    0    0    0     0       0          0
vethc17f3ed: 598684766  902860    0    0    0     0          0         0 557734644  628308    0    0    0     0       0          0
br-c6f16e7854e5: 49658492  470379    0    0    0     0          0        12 2231400175  526754    0    1    0     0       0          0
veth19aa0b7: 27715706  266705    0    0    0     0          0         0 75217423  273540    0    0    0     0       0          0
br-8c9b1dc4fdd3:     252       9    0    0    0     0          0         0     1020      10    0    1    0     0       0          0
veth51bc281:     126       3    0    0    0     0          0         0     9486     133    0    0    0     0       0          0
''';
      expect(parseNetwork(strangeValue), (7506157897, 1994284564));
    });

    test('returns 0 for empty text', () {
      expect(parseNetwork(''), (0, 0));
    });
  });
}
