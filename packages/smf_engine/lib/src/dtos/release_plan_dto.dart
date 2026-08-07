import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/dtos/conventional_change_dto.dart';
import 'package:smf_engine/src/enums/release_platform.dart';
import 'package:smf_engine/src/enums/version_bump_type.dart';

part 'release_plan_dto.freezed.dart';
part 'release_plan_dto.g.dart';

/// A deterministic platform release proposed from repository history.
@freezed
abstract class ReleasePlanDto with _$ReleasePlanDto {
  /// Creates a release plan.
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory ReleasePlanDto({
    required ReleasePlatform platform,
    required String currentVersion,
    required String nextVersion,
    required VersionBumpType versionBumpType,
    required String baseCommitHash,
    required String endCommitHash,
    required List<ConventionalChangeDto> changes,
  }) = _ReleasePlanDto;

  /// Decodes a release plan from JSON.
  factory ReleasePlanDto.fromJson(Map<String, Object?> json) => _$ReleasePlanDtoFromJson(json);
}
