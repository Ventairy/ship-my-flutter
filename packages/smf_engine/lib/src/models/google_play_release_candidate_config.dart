import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/models/release_enums.dart';

part 'google_play_release_candidate_config.freezed.dart';

/// Google Play delivery used while the release PR is open.
@freezed
abstract class GooglePlayReleaseCandidateConfig with _$GooglePlayReleaseCandidateConfig {
  /// Creates Google Play release-candidate configuration.
  const factory GooglePlayReleaseCandidateConfig({
    @Default(GooglePlayReleaseCandidateTarget.internalTesting) GooglePlayReleaseCandidateTarget target,
    @Default(<String>[]) List<String> tracks,
  }) = _GooglePlayReleaseCandidateConfig;
}
