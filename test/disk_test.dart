import 'package:test/test.dart';
import 'package:vigie/src/system/overview.dart';

const sortiDf = '''
Filesystem     1024-blocks     Used Available Capacity Mounted on
/dev/sda1        202218608 25636648 176565576      13% /
/dev/sda13         1012140   178668    764712      19% /boot
/dev/sda15          106832     6414    100418       7% /boot/efi
''';

void main() {
  group('parseDisks', () {
    test('read 3 part of DF', () {
      expect(parseDisks(sortiDf), hasLength(3));
    });

    test('Read name and space(Used, Free)', () {
      final disk = parseDisks(sortiDf).first;
      expect(disk.name, 'sda1');
      expect(disk.usage, 25636648);
      expect(disk.freeSpace, 176565576);
    });

    test('Check pct', () {
      final disk = parseDisks(sortiDf).first;
      expect(disk.capacity, closeTo(12.67, 0.01));
    });

    test('Check empty text', () {
      expect(parseDisks(''), isEmpty);
    });

    test('Check head integrity', () {
      const head =
          'Filesystem     1024-blocks     Used Available Capacity Mounted on\n';
      expect(parseDisks(head), isEmpty);
    });

    test('Check text integrity', () {
      const strangeText = '''
Filesystem     1024-blocks     Used Available Capacity Mounted on
/dev/sda1        202218608 25636648 176565576      13% /
/dev/sda132        202218612308 
/dev/sda13         1012140   178668    764712      19% /boot
/dev/sda15          106832     6414    100418       7% /boot/efi
''';
      final disks = parseDisks(strangeText);
      expect(disks, hasLength(3));
      expect(disks.last.name, 'sda15');
    });
  });
}
