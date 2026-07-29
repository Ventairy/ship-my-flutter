import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_resource_dto.freezed.dart';
part 'api_resource_dto.g.dart';

/// A typed JSON:API resource returned by App Store Connect.
@Freezed(genericArgumentFactories: true)
abstract class ApiResourceDto<T> with _$ApiResourceDto<T> {
  /// Creates an App Store Connect resource.
  @JsonSerializable(
    checked: true,
    explicitToJson: true,
    genericArgumentFactories: true,
  )
  const factory ApiResourceDto({
    required String type,
    required String id,
    required T attributes,
  }) = _ApiResourceDto<T>;

  /// Decodes an App Store Connect resource from JSON.
  factory ApiResourceDto.fromJson(
    Map<String, Object?> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResourceDtoFromJson(json, fromJsonT);
}
