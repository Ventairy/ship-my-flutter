import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/release_enums.dart';
import 'conventional_change.dart';

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
