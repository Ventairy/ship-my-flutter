import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/models/release_enums.dart';

part 'release_target.freezed.dart';
part 'release_target.g.dart';

/// A platform release routed to a workflow phase.
@freezed
abstract class ReleaseTarget with _$ReleaseTarget {
  /// Creates a platform release target.
  @JsonSerializable(checked: true)
  const factory ReleaseTarget({
    required Platform platform,
    required String version,
  }) = _ReleaseTarget;

  /// Decodes a release target from JSON.
  factory ReleaseTarget.fromJson(Map<String, Object?> json) => _$ReleaseTargetFromJson(json);
}
