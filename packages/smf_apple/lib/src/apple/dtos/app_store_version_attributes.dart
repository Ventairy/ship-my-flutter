import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_apple/src/apple/dtos/apple_platform.dart';

part 'app_store_version_attributes.freezed.dart';
part 'app_store_version_attributes.g.dart';
part 'app_store_version_attributes_enums.dart';

/// App Store version attributes returned by App Store Connect.
@freezed
abstract class AppStoreVersionAttributes with _$AppStoreVersionAttributes {
  /// Creates App Store version attributes.
  @JsonSerializable(checked: true)
  const factory AppStoreVersionAttributes({
    required ApplePlatform platform,
    required String versionString,
    required AppVersionState appVersionState,
    required AppStoreReleaseType releaseType,
  }) = _AppStoreVersionAttributes;

  /// Decodes App Store version attributes from JSON.
  factory AppStoreVersionAttributes.fromJson(Map<String, Object?> json) => _$AppStoreVersionAttributesFromJson(json);
}
