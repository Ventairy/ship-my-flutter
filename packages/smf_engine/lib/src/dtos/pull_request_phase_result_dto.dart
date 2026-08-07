import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/dtos/release_target_dto.dart';

part 'pull_request_phase_result_dto.freezed.dart';
part 'pull_request_phase_result_dto.g.dart';

/// Routing decision produced by the pull-request release phase.
@Freezed(
  unionKey: 'nextPhase',
  unionValueCase: FreezedUnionCase.kebab,
)
sealed class PullRequestPhaseResultDto with _$PullRequestPhaseResultDto {
  /// Stops the workflow because no release work is eligible.
  @JsonSerializable(
    checked: true,
    includeIfNull: false,
    explicitToJson: true,
  )
  const factory PullRequestPhaseResultDto.noop() = PullRequestNoopResultDto;

  /// Routes the selected [targets] to release-candidate creation.
  @JsonSerializable(
    checked: true,
    includeIfNull: false,
    explicitToJson: true,
  )
  const factory PullRequestPhaseResultDto.releaseCandidate({
    required List<ReleaseTargetDto> targets,
    required String releaseBranch,
    int? pullRequestNumber,
  }) = PullRequestReleaseCandidateResultDto;

  /// Routes the selected [targets] to shipping.
  @JsonSerializable(
    checked: true,
    includeIfNull: false,
    explicitToJson: true,
  )
  const factory PullRequestPhaseResultDto.ship({
    required List<ReleaseTargetDto> targets,
  }) = PullRequestShipResultDto;

  /// Decodes a pull-request phase result from JSON.
  factory PullRequestPhaseResultDto.fromJson(Map<String, Object?> json) => _$PullRequestPhaseResultDtoFromJson(json);
}
