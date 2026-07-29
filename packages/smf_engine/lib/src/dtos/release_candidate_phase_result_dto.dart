import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/dtos/release_candidate_receipt_dto.dart';

part 'release_candidate_phase_result_dto.freezed.dart';
part 'release_candidate_phase_result_dto.g.dart';

/// Exact candidate evidence produced by the release-candidate phase.
@freezed
abstract class ReleaseCandidatePhaseResultDto with _$ReleaseCandidatePhaseResultDto {
  /// Creates a result for the uploaded or reused [releaseCandidateReceipts].
  @JsonSerializable(
    checked: true,
    explicitToJson: true,
  )
  const factory ReleaseCandidatePhaseResultDto({
    required List<ReleaseCandidateReceiptDto> releaseCandidateReceipts,
  }) = _ReleaseCandidatePhaseResultDto;

  /// Decodes a release-candidate phase result from JSON.
  factory ReleaseCandidatePhaseResultDto.fromJson(
    Map<String, Object?> json,
  ) => _$ReleaseCandidatePhaseResultDtoFromJson(json);
}
