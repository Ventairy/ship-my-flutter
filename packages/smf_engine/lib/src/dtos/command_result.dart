import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/dtos/release_target.dart';

part 'command_result.freezed.dart';
part 'command_result.g.dart';

/// Stable machine-readable output emitted by a workflow operation.
@freezed
abstract class CommandResult with _$CommandResult {
  /// Creates a command result.
  @JsonSerializable(
    checked: true,
    includeIfNull: false,
    explicitToJson: true,
  )
  const factory CommandResult({
    required String phase,
    List<ReleaseTarget>? releases,
    String? branch,
    int? pullRequestNumber,
  }) = _CommandResult;

  /// Decodes command output from JSON.
  factory CommandResult.fromJson(Map<String, Object?> json) =>
      _$CommandResultFromJson(json);
}
