import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/dtos/changelog_platform_release_version_dto.dart';

part 'changelog_platform_dto.freezed.dart';
part 'changelog_platform_dto.g.dart';

/// Changelog state for one release platform.
@freezed
abstract class ChangelogPlatformDto with _$ChangelogPlatformDto {
  /// Creates one platform's changelog state.
  @JsonSerializable(
    checked: true,
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
  )
  const factory ChangelogPlatformDto({
    @JsonKey(required: true, disallowNullValue: true) required List<ChangelogPlatformReleaseVersionDto> releases,
  }) = _ChangelogPlatformDto;

  /// Decodes one platform's changelog state.
  factory ChangelogPlatformDto.fromJson(
    Map<String, Object?> json,
  ) => _$ChangelogPlatformDtoFromJson(json);

  const ChangelogPlatformDto._();

  /// Finds the release whose marketing version exactly matches [version].
  ChangelogPlatformReleaseVersionDto? releaseVersion(String version) {
    return releases.where((release) => release.version == version).firstOrNull;
  }
}
