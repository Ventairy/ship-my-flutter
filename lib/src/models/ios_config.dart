import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_store_config.dart';
import 'testflight_config.dart';

part 'ios_config.freezed.dart';

/// iOS project, build, TestFlight, and App Store configuration.
@freezed
abstract class IosConfig with _$IosConfig {
  /// Creates iOS configuration.
  const factory IosConfig({
    @Default(true) bool enabled,
    String? bundleId,
    String? buildCommand,
    @Default('build/ios/ipa') String ipaOutputPath,
    @Default(TestflightConfig()) TestflightConfig testflight,
    @Default(AppStoreConfig()) AppStoreConfig appStore,
  }) = _IosConfig;
}
