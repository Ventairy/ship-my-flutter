import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/dtos/changelog_platform_dto.dart';
import 'package:smf_engine/src/enums/release_platform.dart';

part 'changelog_platforms_dto.freezed.dart';
part 'changelog_platforms_dto.g.dart';

/// Platform objects nested under `platforms` in `smf/changelog.json`.
@freezed
abstract class ChangelogPlatformsDto with _$ChangelogPlatformsDto {
  /// Creates the platform changelog objects.
  @JsonSerializable(
    checked: true,
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
  )
  const factory ChangelogPlatformsDto({
    @JsonKey(required: true, disallowNullValue: true) required ChangelogPlatformDto ios,
    @JsonKey(required: true, disallowNullValue: true) required ChangelogPlatformDto android,
  }) = _ChangelogPlatformsDto;

  /// Decodes the platform changelog objects.
  factory ChangelogPlatformsDto.fromJson(Map<String, Object?> json) => _$ChangelogPlatformsDtoFromJson(json);

  const ChangelogPlatformsDto._();

  /// Selects and returns the changelog state for [platform].
  ChangelogPlatformDto select(ReleasePlatform platform) => switch (platform) {
    ReleasePlatform.ios => ios,
    ReleasePlatform.android => android,
  };
}
