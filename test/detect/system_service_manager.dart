import 'package:test/test.dart';
import 'package:vigie/src/system/services.dart';

void main() {
    group('detectServiceManager', () {
      test('detects systemd when its run directory exists', () {
        expect(detectServiceManager((p) => p == '/run/systemd/system'), ServiceManager.systemd);
      });
    });
}
