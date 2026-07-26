import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

void main() {
  test(
    'when copying configuration, it should preserve unchanged nested values',
    () {
      const config = ShipConfig(
        targetBranch: 'main',
        ios: IosConfig(bundleId: 'dev.example.app'),
      );

      expect(
        config.copyWith(targetBranch: 'stable'),
        const ShipConfig(
          targetBranch: 'stable',
          ios: IosConfig(bundleId: 'dev.example.app'),
        ),
      );
    },
  );
}
