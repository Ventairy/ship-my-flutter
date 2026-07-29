import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/dtos/manifest_platforms_dto.dart';
import 'package:smf_engine/src/dtos/platform_manifest_dto.dart';
import 'package:smf_engine/src/enums/release_platform.dart';

part 'manifest_dto.freezed.dart';
part 'manifest_dto.g.dart';

/// Root document persisted as `smf/manifest.json`.
@freezed
abstract class ManifestDto with _$ManifestDto {
  /// Creates the repository release manifest.
  @JsonSerializable(
    checked: true,
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
  )
  const factory ManifestDto({
    @JsonKey(required: true, disallowNullValue: true) required ManifestPlatformsDto platforms,
    @JsonKey(
      required: true,
      disallowNullValue: true,
      fromJson: ManifestDto._schemaVersionFromJson,
    )
    required int schemaVersion,
  }) = _ManifestDto;

  /// Decodes the complete release manifest.
  factory ManifestDto.fromJson(Map<String, Object?> json) => _$ManifestDtoFromJson(json);

  const ManifestDto._();

  static int _schemaVersionFromJson(Object? value) {
    if (value == 1) return 1;
    throw const FormatException('schemaVersion must be 1');
  }

  /// Returns release state for [platform].
  PlatformManifestDto forPlatform(ReleasePlatform platform) => platforms.forPlatform(platform);
}
