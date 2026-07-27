import 'package:freezed_annotation/freezed_annotation.dart';

import 'hooks_config.dart';
import 'ios_config.dart';

part 'ship_config.freezed.dart';

/// Validated ship-my-flutter repository configuration.
@freezed
abstract class ShipConfig with _$ShipConfig {
  /// Creates repository configuration.
  const factory ShipConfig({
    @Default(1) int schemaVersion,
    @Default('.') String appPath,
    String? flavor,
    @Default('main') String targetBranch,
    @Default(HooksConfig()) HooksConfig hooks,
    required IosConfig ios,
  }) = _ShipConfig;
}
