import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/ios/enums/build_processing_state.dart';

part 'build_attributes_dto.freezed.dart';
part 'build_attributes_dto.g.dart';

/// Build attributes returned by App Store Connect.
@freezed
abstract class BuildAttributesDto with _$BuildAttributesDto {
  /// Creates build attributes.
  @JsonSerializable(checked: true)
  const factory BuildAttributesDto({
    required String version,
    required BuildProcessingState processingState,
    String? uploadedDate,
    @JsonKey(name: 'expired') @Default(false) bool isExpired,
    @JsonKey(name: 'usesNonExemptEncryption') bool? doesUseNonExemptEncryption,
  }) = _BuildAttributesDto;

  /// Decodes build attributes from JSON.
  factory BuildAttributesDto.fromJson(Map<String, Object?> json) => _$BuildAttributesDtoFromJson(json);
}
