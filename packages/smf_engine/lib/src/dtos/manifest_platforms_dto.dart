import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/dtos/platform_manifest_dto.dart';
import 'package:smf_engine/src/enums/release_platform.dart';

part 'manifest_platforms_dto.freezed.dart';
part 'manifest_platforms_dto.g.dart';

/// Platform objects nested under `platforms` in `smf/manifest.json`.
@freezed
abstract class ManifestPlatformsDto with _$ManifestPlatformsDto {
  /// Creates the platform release-state objects.
  @JsonSerializable(
    checked: true,
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
  )
  const factory ManifestPlatformsDto({
    @JsonKey(required: true, disallowNullValue: true) required PlatformManifestDto ios,
    @JsonKey(required: true, disallowNullValue: true) required PlatformManifestDto android,
  }) = _ManifestPlatformsDto;

  /// Decodes the platform release-state objects.
  factory ManifestPlatformsDto.fromJson(Map<String, Object?> json) => _$ManifestPlatformsDtoFromJson(json);

  const ManifestPlatformsDto._();

  /// Returns release state for [platform].
  PlatformManifestDto forPlatform(ReleasePlatform platform) => switch (platform) {
    ReleasePlatform.ios => ios,
    ReleasePlatform.android => android,
  };
}
