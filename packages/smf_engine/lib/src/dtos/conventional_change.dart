import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/models/release_enums.dart';

part 'conventional_change.freezed.dart';
part 'conventional_change.g.dart';

/// A parsed Conventional Commit included in platform release state.
@freezed
abstract class ConventionalChange with _$ConventionalChange {
  /// Creates a parsed change.
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory ConventionalChange({
    required String sha,
    required String type,
    required String? scope,
    required String description,
    required String? body,
    required bool breaking,
    required Bump? bump,
    required List<Platform> platforms,
    @JsonKey(includeIfNull: false) String? releaseAs,
  }) = _ConventionalChange;

  /// Decodes typed change fields without changelog-domain validation.
  ///
  /// Use `validateChangelog` when reading user repository state.
  factory ConventionalChange.fromJson(Map<String, Object?> json) =>
      _$ConventionalChangeFromJson(json);
}
