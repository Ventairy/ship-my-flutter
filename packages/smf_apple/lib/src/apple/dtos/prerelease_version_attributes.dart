import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_apple/src/apple/dtos/apple_platform.dart';

part 'prerelease_version_attributes.freezed.dart';
part 'prerelease_version_attributes.g.dart';

/// Prerelease-version attributes returned by App Store Connect.
@freezed
abstract class PrereleaseVersionAttributes with _$PrereleaseVersionAttributes {
  /// Creates prerelease-version attributes.
  @JsonSerializable(checked: true)
  const factory PrereleaseVersionAttributes({
    required String version,
    required ApplePlatform platform,
  }) = _PrereleaseVersionAttributes;

  /// Decodes prerelease-version attributes from JSON.
  factory PrereleaseVersionAttributes.fromJson(Map<String, Object?> json) =>
      _$PrereleaseVersionAttributesFromJson(json);
}
