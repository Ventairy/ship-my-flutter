import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_resource.freezed.dart';
part 'api_resource.g.dart';

/// A typed JSON:API resource returned by App Store Connect.
@Freezed(genericArgumentFactories: true)
abstract class ApiResource<T> with _$ApiResource<T> {
  /// Creates an App Store Connect resource.
  @JsonSerializable(
    checked: true,
    explicitToJson: true,
    genericArgumentFactories: true,
  )
  const factory ApiResource({
    required String type,
    required String id,
    required T attributes,
  }) = _ApiResource<T>;

  /// Decodes an App Store Connect resource from JSON.
  factory ApiResource.fromJson(
    Map<String, Object?> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResourceFromJson(json, fromJsonT);
}
