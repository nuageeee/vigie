import 'package:test/test.dart';
import 'package:vigie/src/system/overview.dart';

void main() { 
  group('_cpuModel', () {
    test('reads the model name on x86', () {
      expect(parseCpuModel('processor\t: 0\nmodel\t\t: 1\nmodel name\t: AMD EPYC 7763 64-Core Processor\n'), 'AMD EPYC 7763 64-Core Processor');
    });
    test('takes the first model name only', () {
      expect(parseCpuModel('model name\t: A\n\nmodel name\t: B\n'), 'A');
    });
    test('falls back to Model oon Raspberry Pi', () {
      expect(parseCpuModel('processor\t: 0\nModel\t\t: Raspberry Pi 4 Model B Rev 1.4\n'), 'Raspberry Pi 4 Model B Rev 1.4');
    });
    test('does not confuse model with model name', () {
      expect(parseCpuModel('model\t\t: 85\n'), '-');
    });
    test('returns a dash when nothing is found', () {
      expect(parseCpuModel(''), '-');
    });
  });
}
