import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/android/models/android_config.dart';
import 'package:smf_engine/src/enums/release_platform.dart';
import 'package:smf_engine/src/ios/models/ios_config.dart';

part 'smf_config.freezed.dart';

/// Validated SMF application configuration.
@freezed
abstract class SmfConfig with _$SmfConfig {
  /// Creates application configuration.
  const factory SmfConfig({
    required String appId,
    @Default(IosConfig(isEnabled: false)) IosConfig ios,
    @Default(AndroidConfig()) AndroidConfig android,
    @Default(SmfConfig.currentSchemaVersion) int schemaVersion,
    String? flavor,
    @Default('main') String targetBranch,
    @Default(<String>[]) List<String> releaseTriggerPaths,
  }) = _SmfConfig;

  const SmfConfig._();

  /// Current `smf/config.yaml` contract version.
  static const int currentSchemaVersion = 1;

  /// Enabled release platforms in deterministic workflow order.
  List<ReleasePlatform> get enabledPlatforms => <ReleasePlatform>[
    if (ios.isEnabled) ReleasePlatform.ios,
    if (android.isEnabled) ReleasePlatform.android,
  ];
}
