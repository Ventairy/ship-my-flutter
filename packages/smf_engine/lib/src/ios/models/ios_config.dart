import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/ios/models/app_store_config.dart';

part 'ios_config.freezed.dart';

/// iOS project, build, TestFlight, and App Store configuration.
@freezed
abstract class IosConfig with _$IosConfig {
  /// Creates iOS configuration.
  const factory IosConfig({
    @Default(true) bool isEnabled,
    @Default('0.0.0') String initialVersion,
    String? bundleId,
    String? buildCommand,
    @Default('build/ios/ipa') String ipaOutputPath,
    @Default(AppStoreConfig()) AppStoreConfig appStore,
  }) = _IosConfig;
}
