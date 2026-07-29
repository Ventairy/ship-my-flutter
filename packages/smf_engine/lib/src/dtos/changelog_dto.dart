import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/dtos/changelog_platforms_dto.dart';

part 'changelog_dto.freezed.dart';
part 'changelog_dto.g.dart';

/// Root document persisted as `smf/changelog.json`.
@freezed
abstract class ChangelogDto with _$ChangelogDto {
  /// Creates the complete changelog document.
  @JsonSerializable(
    checked: true,
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
  )
  const factory ChangelogDto({
    @JsonKey(required: true, disallowNullValue: true) required ChangelogPlatformsDto platforms,
    @JsonKey(
      required: true,
      disallowNullValue: true,
      fromJson: ChangelogDto._schemaVersionFromJson,
    )
    required int schemaVersion,
  }) = _ChangelogDto;

  /// Decodes the complete changelog document.
  factory ChangelogDto.fromJson(Map<String, Object?> json) => _$ChangelogDtoFromJson(json);

  const ChangelogDto._();

  static int _schemaVersionFromJson(Object? value) {
    if (value == 1) return 1;
    throw const FormatException('schemaVersion must be 1');
  }
}
