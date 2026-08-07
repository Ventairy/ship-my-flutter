import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/ios/enums/apple_release_candidate_target.dart';

part 'apple_release_candidate_config.freezed.dart';

/// TestFlight delivery used while the release PR is open.
@freezed
abstract class AppleReleaseCandidateConfig with _$AppleReleaseCandidateConfig {
  /// Creates Apple release-candidate configuration.
  const factory AppleReleaseCandidateConfig({
    @Default(AppleReleaseCandidateTarget.internalTesting) AppleReleaseCandidateTarget target,
    @Default(<String>[]) List<String> groups,
    @Default(45) int waitTimeoutMinutes,
  }) = _AppleReleaseCandidateConfig;
}
