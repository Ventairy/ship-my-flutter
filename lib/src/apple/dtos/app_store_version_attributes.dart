import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_store_version_attributes.freezed.dart';
part 'app_store_version_attributes.g.dart';

/// App Store version attributes returned by App Store Connect.
@freezed
abstract class AppStoreVersionAttributes with _$AppStoreVersionAttributes {
  /// Creates App Store version attributes.
  @JsonSerializable(checked: true)
  const factory AppStoreVersionAttributes({
    required String platform,
    required String versionString,
    required String appStoreState,
    required String releaseType,
    String? earliestReleaseDate,
  }) = _AppStoreVersionAttributes;

  /// Decodes App Store version attributes from JSON.
  factory AppStoreVersionAttributes.fromJson(Map<String, Object?> json) =>
      _$AppStoreVersionAttributesFromJson(json);
}
