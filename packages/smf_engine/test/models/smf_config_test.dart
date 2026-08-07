import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when copying configuration, it should preserve unchanged nested values',
    () {
      const config = SmfConfig(
        appId: 'example',
        ios: IosConfig(bundleId: 'dev.example.app'),
      );

      expect(
        config.copyWith(targetBranch: 'stable'),
        const SmfConfig(
          appId: 'example',
          targetBranch: 'stable',
          ios: IosConfig(bundleId: 'dev.example.app'),
        ),
      );
    },
  );
}
