import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_attributes.freezed.dart';
part 'app_attributes.g.dart';

/// App attributes returned by App Store Connect.
@freezed
abstract class AppAttributes with _$AppAttributes {
  /// Creates app attributes.
  @JsonSerializable(checked: true)
  const factory AppAttributes({
    required String name,
    required String bundleId,
    required String sku,
    required String primaryLocale,
  }) = _AppAttributes;

  /// Decodes app attributes from JSON.
  factory AppAttributes.fromJson(Map<String, Object?> json) =>
      _$AppAttributesFromJson(json);
}
