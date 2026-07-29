import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/ios/enums/apple_ship_target.dart';

part 'apple_ship_config.freezed.dart';

/// Apple delivery performed after the exact release candidate is approved and merged.
@freezed
abstract class AppleShipConfig with _$AppleShipConfig {
  /// Creates Apple ship configuration.
  const factory AppleShipConfig({
    required AppleShipTarget target,
    @Default(<String>[]) List<String> groups,
  }) = _AppleShipConfig;
}
