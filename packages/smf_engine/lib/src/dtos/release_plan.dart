import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/dtos/conventional_change.dart';
import 'package:smf_engine/src/models/release_enums.dart';

part 'release_plan.freezed.dart';
part 'release_plan.g.dart';

/// A deterministic platform release proposed from repository history.
@freezed
abstract class ReleasePlan with _$ReleasePlan {
  /// Creates a release plan.
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory ReleasePlan({
    required Platform platform,
    required String currentVersion,
    required String nextVersion,
    required Bump bump,
    required String baseSha,
    required String headSha,
    required List<ConventionalChange> changes,
  }) = _ReleasePlan;

  /// Decodes a release plan from JSON.
  factory ReleasePlan.fromJson(Map<String, Object?> json) =>
      _$ReleasePlanFromJson(json);
}
