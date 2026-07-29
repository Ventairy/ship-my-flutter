import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_attributes_dto.freezed.dart';
part 'app_attributes_dto.g.dart';

/// App attributes returned by App Store Connect.
@freezed
abstract class AppAttributesDto with _$AppAttributesDto {
  /// Creates app attributes.
  @JsonSerializable(checked: true)
  const factory AppAttributesDto({
    required String name,
    required String bundleId,
    required String sku,
    required String primaryLocale,
  }) = _AppAttributesDto;

  /// Decodes app attributes from JSON.
  factory AppAttributesDto.fromJson(Map<String, Object?> json) => _$AppAttributesDtoFromJson(json);
}
