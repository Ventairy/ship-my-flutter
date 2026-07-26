import 'package:freezed_annotation/freezed_annotation.dart';

import 'hooks_config.dart';
import 'ios_config.dart';

part 'ship_config.freezed.dart';

/// Validated ship-my-flutter repository configuration.
@freezed
abstract class ShipConfig with _$ShipConfig {
  /// Creates repository configuration.
  const factory ShipConfig({
    @Default(2) int schemaVersion,
    @Default('main') String targetBranch,
    @Default('ship-my-flutter') String releaseBranchPrefix,
    @Default(HooksConfig()) HooksConfig hooks,
    required IosConfig ios,
  }) = _ShipConfig;
}
