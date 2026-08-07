import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/dtos/conventional_change_dto.dart';

part 'changelog_platform_release_version_dto.freezed.dart';
part 'changelog_platform_release_version_dto.g.dart';

/// One version value nested in a platform's `releases` JSON object.
@freezed
abstract class ChangelogPlatformReleaseVersionDto with _$ChangelogPlatformReleaseVersionDto {
  /// Creates one version's changelog data.
  @JsonSerializable(
    checked: true,
    dateTimeUtc: true,
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
  )
  const factory ChangelogPlatformReleaseVersionDto({
    @JsonKey(required: true, disallowNullValue: true) required String version,
    @JsonKey(required: true, disallowNullValue: true) required DateTime preparedAt,
    @JsonKey(required: true, disallowNullValue: true) required String baseCommitHash,
    @JsonKey(required: true, disallowNullValue: true) required String endCommitHash,
    @JsonKey(required: true, disallowNullValue: true) required List<ConventionalChangeDto> changes,
  }) = _ChangelogPlatformReleaseVersionDto;

  /// Decodes one version's changelog data without domain validation.
  ///
  /// Use `SmfState.parseChangelog` when reading repository state.
  factory ChangelogPlatformReleaseVersionDto.fromJson(Map<String, Object?> json) =>
      _$ChangelogPlatformReleaseVersionDtoFromJson(json);
}
