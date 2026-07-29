import 'package:json_annotation/json_annotation.dart';

/// A phase or no-op result of the SMF release workflow.
@JsonEnum(valueField: 'value')
enum ReleasePhase {
  /// No release work is currently eligible.
  noop('noop'),

  /// Plans releases and creates or updates the release pull request.
  pullRequest('pull-request'),

  /// Builds and uploads release candidates for testing.
  releaseCandidate('release-candidate'),

  /// Promotes tested release candidates after the release pull request merges.
  ship('ship');

  const ReleasePhase(this.value);

  /// Stable CLI and workflow representation.
  final String value;

  /// Whether this phase can be requested through the release command.
  bool get isRunnable => this != ReleasePhase.noop;

  /// Parses [value], or returns `null` when it is not a release phase.
  static ReleasePhase? tryParse(String value) => switch (value) {
    'noop' => ReleasePhase.noop,
    'pull-request' => ReleasePhase.pullRequest,
    'release-candidate' => ReleasePhase.releaseCandidate,
    'ship' => ReleasePhase.ship,
    _ => null,
  };
}
