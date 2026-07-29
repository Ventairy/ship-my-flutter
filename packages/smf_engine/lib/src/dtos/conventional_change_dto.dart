import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/enums/release_platform.dart';
import 'package:smf_engine/src/enums/version_bump_type.dart';

part 'conventional_change_dto.freezed.dart';
part 'conventional_change_dto.g.dart';

/// A parsed Conventional Commit included in platform release state.
@freezed
abstract class ConventionalChangeDto with _$ConventionalChangeDto {
  /// Creates a parsed change.
  @JsonSerializable(
    checked: true,
    disallowUnrecognizedKeys: true,
    explicitToJson: true,
  )
  const factory ConventionalChangeDto({
    @JsonKey(required: true, disallowNullValue: true) required String commitHash,
    @JsonKey(required: true, disallowNullValue: true) required String type,
    @JsonKey(required: true) required String? scope,
    @JsonKey(required: true, disallowNullValue: true) required String description,
    @JsonKey(required: true) required String? body,
    @JsonKey(required: true, disallowNullValue: true) required bool isBreaking,
    @JsonKey(required: true) required VersionBumpType? versionBumpType,
    @JsonKey(required: true, disallowNullValue: true) required List<ReleasePlatform> platforms,
  }) = _ConventionalChangeDto;

  /// Decodes typed change fields without changelog-domain validation.
  ///
  /// Use `SmfState.parseChangelog` when reading repository state.
  factory ConventionalChangeDto.fromJson(Map<String, Object?> json) => _$ConventionalChangeDtoFromJson(json);
}
