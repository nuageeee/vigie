import 'package:test/test.dart';
import 'package:vigie/src/system/overview.dart';


const fakeFile = '''
   7       0 loop0 100 0 2000 10 0 0 0 0 0 10 10
   8       0 sda 12345 678 2000 9876 5432 109 1000 4321 0 8765 14197
   8       1 sda1 12000 600 1500 9000 5000 100 800 4000 0 8000 13000
 253       0 dm-0 500 0 400 100 300 0 200 50 0 100 150
 259       0 nvme0n1 100 0 3000 20 50 0 500 10 0 30 30
 259       1 nvme0n1p1 90 0 2900 18 45 0 480 9 0 28 27
 ''';

void main() {
  group('parseDiskStats', () {
    test('sums only whole disks', () {
      expect(parseDiskStats(fakeFile), (2560000, 768000));
    });
    test('returns zero for empty input', () {
      expect(parseDiskStats(''), (0, 0));
    });
    test('skips line with too few fields', () {
      expect(parseDiskStats('   8       0 sda 12 34'), (0, 0));
    });
  });
}