import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/ios/models/apple_release_candidate_config.dart';
import 'package:smf_engine/src/ios/models/apple_ship_config.dart';

part 'app_store_config.freezed.dart';

/// TestFlight release-candidate and App Store ship configuration.
@freezed
abstract class AppStoreConfig with _$AppStoreConfig {
  /// Creates App Store configuration.
  const factory AppStoreConfig({
    @Default(AppleReleaseCandidateConfig()) AppleReleaseCandidateConfig releaseCandidate,
    AppleShipConfig? ship,
  }) = _AppStoreConfig;
}
