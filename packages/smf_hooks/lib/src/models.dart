/// A release platform exposed to repository hooks.
enum Platform {
  /// Apple's iOS platform.
  ios,

  /// Google's Android platform.
  android;

  /// The stable serialized platform name.
  String get value => name;

  /// Parses a serialized platform name.
  static Platform parse(String value) => switch (value) {
    'ios' => Platform.ios,
    'android' => Platform.android,
    _ => throw FormatException('Unsupported platform "$value".'),
  };
}

/// A semantic-version change exposed to repository hooks.
enum Bump {
  /// A patch release.
  patch,

  /// A minor release.
  minor,

  /// A major release.
  major;

  /// Parses an optional serialized bump.
  static Bump? maybeParse(Object? value) => switch (value) {
    null => null,
    'patch' => Bump.patch,
    'minor' => Bump.minor,
    'major' => Bump.major,
    _ => throw FormatException('Unsupported version bump "$value".'),
  };
}

/// One Conventional Commit included in a hook release context.
final class ConventionalChange {
  /// Creates a hook-visible release change.
  const ConventionalChange({
    required this.sha,
    required this.type,
    required this.scope,
    required this.description,
    required this.body,
    required this.breaking,
    required this.bump,
    required this.platforms,
    required this.releaseAs,
  });

  /// Decodes a release change from the hook protocol.
  factory ConventionalChange.fromJson(Map<String, Object?> json) =>
      ConventionalChange(
        sha: _string(json, 'sha'),
        type: _string(json, 'type'),
        scope: _optionalString(json, 'scope'),
        description: _string(json, 'description'),
        body: _optionalString(json, 'body'),
        breaking: _bool(json, 'breaking'),
        bump: Bump.maybeParse(json['bump']),
        platforms: _list(json, 'platforms')
            .map((value) => Platform.parse(value.toString()))
            .toList(growable: false),
        releaseAs: _optionalString(json, 'releaseAs'),
      );

  /// Source commit SHA.
  final String sha;

  /// Conventional Commit type.
  final String type;

  /// Optional Conventional Commit scope.
  final String? scope;

  /// Commit description.
  final String description;

  /// Optional commit body.
  final String? body;

  /// Whether the change is breaking.
  final bool breaking;

  /// Explicit semantic bump, when present.
  final Bump? bump;

  /// Platforms affected by the change.
  final List<Platform> platforms;

  /// Explicit target version, when present.
  final String? releaseAs;
}

/// A deterministic release plan exposed to a before-create-PR hook.
final class ReleasePlan {
  /// Creates a hook-visible release plan.
  const ReleasePlan({
    required this.platform,
    required this.currentVersion,
    required this.nextVersion,
    required this.bump,
    required this.baseSha,
    required this.headSha,
    required this.changes,
  });

  /// Decodes a release plan from the hook protocol.
  factory ReleasePlan.fromJson(Map<String, Object?> json) => ReleasePlan(
    platform: Platform.parse(_string(json, 'platform')),
    currentVersion: _string(json, 'currentVersion'),
    nextVersion: _string(json, 'nextVersion'),
    bump:
        Bump.maybeParse(json['bump']) ??
        (throw const FormatException('bump is required.')),
    baseSha: _string(json, 'baseSha'),
    headSha: _string(json, 'headSha'),
    changes: _list(json, 'changes')
        .map((value) => ConventionalChange.fromJson(_object(value, 'change')))
        .toList(growable: false),
  );

  /// Target platform.
  final Platform platform;

  /// Version before the release.
  final String currentVersion;

  /// Planned release version.
  final String nextVersion;

  /// Planned semantic bump.
  final Bump bump;

  /// Release range base SHA.
  final String baseSha;

  /// Release range head SHA.
  final String headSha;

  /// Included changes.
  final List<ConventionalChange> changes;
}

/// Changelog data exposed to a before-build hook.
final class ChangelogRelease {
  /// Creates hook-visible changelog data.
  const ChangelogRelease({
    required this.version,
    required this.preparedAt,
    required this.baseSha,
    required this.headSha,
    required this.changes,
  });

  /// Decodes changelog data from the hook protocol.
  factory ChangelogRelease.fromJson(Map<String, Object?> json) =>
      ChangelogRelease(
        version: _string(json, 'version'),
        preparedAt: DateTime.parse(_string(json, 'preparedAt')).toUtc(),
        baseSha: _string(json, 'baseSha'),
        headSha: _string(json, 'headSha'),
        changes: _list(json, 'changes')
            .map(
              (value) => ConventionalChange.fromJson(_object(value, 'change')),
            )
            .toList(growable: false),
      );

  /// Platform version.
  final String version;

  /// UTC preparation time.
  final DateTime preparedAt;

  /// Release range base SHA.
  final String baseSha;

  /// Release range head SHA.
  final String headSha;

  /// Included changes.
  final List<ConventionalChange> changes;
}

Map<String, Object?> _object(Object? value, String name) {
  if (value is! Map<Object?, Object?>) {
    throw FormatException('$name must be an object.');
  }
  return <String, Object?>{
    for (final entry in value.entries) entry.key.toString(): entry.value,
  };
}

String _string(Map<String, Object?> json, String name) {
  final value = json[name];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$name must be a non-empty string.');
  }
  return value;
}

String? _optionalString(Map<String, Object?> json, String name) {
  final value = json[name];
  if (value == null) return null;
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$name must be a non-empty string when provided.');
  }
  return value;
}

bool _bool(Map<String, Object?> json, String name) {
  final value = json[name];
  if (value is! bool) throw FormatException('$name must be a boolean.');
  return value;
}

List<Object?> _list(Map<String, Object?> json, String name) {
  final value = json[name];
  if (value is! List<Object?>) throw FormatException('$name must be a list.');
  return value;
}
