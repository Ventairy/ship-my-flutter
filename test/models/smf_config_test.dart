import 'package:smf/smf.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when copying configuration, it should preserve unchanged nested values',
    () {
      const config = SmfConfig(
        targetBranch: 'main',
        ios: IosConfig(bundleId: 'dev.example.app'),
      );

      expect(
        config.copyWith(targetBranch: 'stable'),
        const SmfConfig(
          targetBranch: 'stable',
          ios: IosConfig(bundleId: 'dev.example.app'),
        ),
      );
    },
  );
}
