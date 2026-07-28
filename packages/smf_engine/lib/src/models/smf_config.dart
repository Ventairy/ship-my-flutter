import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/models/android_config.dart';
import 'package:smf_engine/src/models/ios_config.dart';
import 'package:smf_engine/src/models/release_enums.dart';

part 'smf_config.freezed.dart';

/// Validated SMF application configuration.
@freezed
abstract class SmfConfig with _$SmfConfig {
  /// Creates application configuration.
  const factory SmfConfig({
    required String appId,
    @Default(IosConfig(enabled: false)) IosConfig ios,
    @Default(AndroidConfig()) AndroidConfig android,
    @Default(SmfConfig.currentSchemaVersion) int schemaVersion,
    String? flavor,
    @Default('main') String targetBranch,
    @Default(<String>[]) List<String> releaseTriggerPaths,
  }) = _SmfConfig;

  const SmfConfig._();

  /// Current `smf/config.yaml` contract version.
  static const int currentSchemaVersion = 3;

  /// Enabled release platforms in deterministic workflow order.
  List<Platform> get enabledPlatforms => <Platform>[
    if (ios.enabled) Platform.ios,
    if (android.enabled) Platform.android,
  ];
}
