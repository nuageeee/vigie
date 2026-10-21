import 'package:test/test.dart';
import 'package:vigie/src/system/services.dart';

void main() {
  group('detectServiceManager', () {
    test('detects systemd when its run directory exists', () {
      expect(
        detectServiceManager((p) => p == '/run/systemd/system'),
        ServiceManager.systemd,
      );
    });
    test('returns none when the run directory is missing', () {
      expect(detectServiceManager((_) => false), ServiceManager.none);
    });
    test('ignores other directories', () {
      expect(
        detectServiceManager((p) => p == '/run/systemd'),
        ServiceManager.none,
      );
    });
  });
}
