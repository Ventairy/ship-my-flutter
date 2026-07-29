import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_manifest_dto.freezed.dart';
part 'platform_manifest_dto.g.dart';

/// Version and release progress persisted for one platform.
@freezed
abstract class PlatformManifestDto with _$PlatformManifestDto {
  /// Creates platform release state.
  @JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
  const factory PlatformManifestDto({
    @JsonKey(required: true, disallowNullValue: true) required String version,
    @JsonKey(required: true, disallowNullValue: true) required String endCommitHash,
    @JsonKey(required: true, disallowNullValue: true) required bool isReleasePending,
  }) = _PlatformManifestDto;

  /// Decodes typed platform state without repository-domain validation.
  ///
  /// Use `SmfState.parseManifest` when reading repository state.
  factory PlatformManifestDto.fromJson(Map<String, Object?> json) => _$PlatformManifestDtoFromJson(json);
}
