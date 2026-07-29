import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/ios/enums/app_store_release_type.dart';
import 'package:smf_engine/src/ios/enums/app_version_state.dart';
import 'package:smf_engine/src/ios/enums/apple_platform.dart';

part 'app_store_version_attributes_dto.freezed.dart';
part 'app_store_version_attributes_dto.g.dart';

/// App Store version attributes returned by App Store Connect.
@freezed
abstract class AppStoreVersionAttributesDto with _$AppStoreVersionAttributesDto {
  /// Creates App Store version attributes.
  @JsonSerializable(checked: true)
  const factory AppStoreVersionAttributesDto({
    required ApplePlatform platform,
    required String versionString,
    required AppVersionState appVersionState,
    required AppStoreReleaseType releaseType,
  }) = _AppStoreVersionAttributesDto;

  /// Decodes App Store version attributes from JSON.
  factory AppStoreVersionAttributesDto.fromJson(Map<String, Object?> json) =>
      _$AppStoreVersionAttributesDtoFromJson(json);
}
