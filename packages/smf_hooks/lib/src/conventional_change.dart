part of 'smf_hooks_sdk.dart';

/// One Conventional Commit included in an SMF platform release.
final class ConventionalChange {
  /// Creates a hook-visible release change.
  const ConventionalChange._({
    required this.type,
    required this.scope,
    required this.description,
    required this.body,
  });

  /// Conventional Commit type.
  final String type;

  /// Optional Conventional Commit scope.
  final String? scope;

  /// Commit description.
  final String description;

  /// Optional commit body.
  final String? body;
}
