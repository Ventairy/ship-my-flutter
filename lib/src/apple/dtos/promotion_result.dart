import 'package:freezed_annotation/freezed_annotation.dart';

part 'promotion_result.freezed.dart';
part 'promotion_result.g.dart';

/// Stable machine-readable evidence produced after promotion.
@freezed
abstract class PromotionResult with _$PromotionResult {
  /// Creates a promotion result.
  @JsonSerializable(checked: true, includeIfNull: false)
  const factory PromotionResult({
    required String version,
    required String tag,
    required String buildId,
    String? appStoreVersionId,
    String? reviewSubmissionId,
    required String githubReleaseUrl,
  }) = _PromotionResult;

  /// Decodes promotion evidence from JSON.
  factory PromotionResult.fromJson(Map<String, Object?> json) =>
      _$PromotionResultFromJson(json);
}
