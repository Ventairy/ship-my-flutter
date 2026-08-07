import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/ios/enums/apple_platform.dart';

part 'prerelease_version_attributes_dto.freezed.dart';
part 'prerelease_version_attributes_dto.g.dart';

/// Prerelease-version attributes returned by App Store Connect.
@freezed
abstract class PrereleaseVersionAttributesDto with _$PrereleaseVersionAttributesDto {
  /// Creates prerelease-version attributes.
  @JsonSerializable(checked: true)
  const factory PrereleaseVersionAttributesDto({
    required String version,
    required ApplePlatform platform,
  }) = _PrereleaseVersionAttributesDto;

  /// Decodes prerelease-version attributes from JSON.
  factory PrereleaseVersionAttributesDto.fromJson(Map<String, Object?> json) =>
      _$PrereleaseVersionAttributesDtoFromJson(json);
}
