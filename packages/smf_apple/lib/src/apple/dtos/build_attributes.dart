import 'package:freezed_annotation/freezed_annotation.dart';

part 'build_attributes.freezed.dart';
part 'build_attributes.g.dart';
part 'build_attributes_enums.dart';

/// Build attributes returned by App Store Connect.
@freezed
abstract class BuildAttributes with _$BuildAttributes {
  /// Creates build attributes.
  @JsonSerializable(checked: true)
  const factory BuildAttributes({
    required String version,
    required BuildProcessingState processingState,
    String? uploadedDate,
    @Default(false) bool expired,
    bool? usesNonExemptEncryption,
  }) = _BuildAttributes;

  /// Decodes build attributes from JSON.
  factory BuildAttributes.fromJson(Map<String, Object?> json) => _$BuildAttributesFromJson(json);
}
