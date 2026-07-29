import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/enums/release_platform.dart';

part 'apple_ship_release_result_dto.freezed.dart';
part 'apple_ship_release_result_dto.g.dart';

/// Stable machine-readable evidence produced after shipping an Apple release.
@freezed
abstract class AppleShipReleaseResultDto with _$AppleShipReleaseResultDto {
  /// Creates an Apple ship result.
  @JsonSerializable(checked: true, includeIfNull: false)
  const factory AppleShipReleaseResultDto({
    required String version,
    required String tag,
    required String artifactId,
    required String buildNumber,
    required String githubReleaseUrl,
    @Default(ReleasePlatform.ios) ReleasePlatform platform,
    String? appStoreVersionId,
    String? reviewSubmissionId,
    String? betaReviewSubmissionId,
  }) = _AppleShipReleaseResultDto;

  /// Decodes Apple ship evidence from JSON.
  factory AppleShipReleaseResultDto.fromJson(Map<String, Object?> json) => _$AppleShipReleaseResultDtoFromJson(json);
}
