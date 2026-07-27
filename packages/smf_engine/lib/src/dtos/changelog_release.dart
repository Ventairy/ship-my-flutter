import 'package:freezed_annotation/freezed_annotation.dart';

import 'conventional_change.dart';
import 'utc_date_time_converter.dart';

part 'changelog_release.freezed.dart';
part 'changelog_release.g.dart';

/// Auditable changelog data for one platform version.
@freezed
abstract class ChangelogRelease with _$ChangelogRelease {
  /// Creates a changelog release.
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory ChangelogRelease({
    required String version,
    @UtcDateTimeConverter() required DateTime preparedAt,
    required String baseSha,
    required String headSha,
    required List<ConventionalChange> changes,
  }) = _ChangelogRelease;

  /// Decodes typed release fields without changelog-domain validation.
  ///
  /// Use `validateChangelog` when reading user repository state.
  factory ChangelogRelease.fromJson(Map<String, Object?> json) =>
      _$ChangelogReleaseFromJson(json);
}
