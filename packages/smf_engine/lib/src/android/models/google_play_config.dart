import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/android/models/google_play_release_candidate_config.dart';
import 'package:smf_engine/src/android/models/google_play_ship_config.dart';

part 'google_play_config.freezed.dart';

/// Google Play testing and production delivery configuration.
@freezed
abstract class GooglePlayConfig with _$GooglePlayConfig {
  /// Creates Google Play configuration.
  const factory GooglePlayConfig({
    @Default(GooglePlayReleaseCandidateConfig()) GooglePlayReleaseCandidateConfig releaseCandidate,
    GooglePlayShipConfig? ship,
  }) = _GooglePlayConfig;
}
