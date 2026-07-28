import 'dart:convert';
import 'dart:io';

enum HookReleasePlatform {
  ios(characterLimit: 4000),
  android(characterLimit: 500);

  const HookReleasePlatform({required this.characterLimit});

  final int characterLimit;
}

/// One Conventional Commit included in an SMF platform release.
final class ConventionalChange {
  /// Creates a hook-visible release change.
  const ConventionalChange({
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

/// One pending platform release supplied to an application's create-PR hook.
final class PlatformRelease {
  PlatformRelease._({
    required this.nextVersion,
    required this.changes,
    required this.storeReleaseNotes,
  });

  factory PlatformRelease.fromJson(
    Map<String, Object?> json, {
    required HookReleasePlatform platform,
    required File storeReleaseNotesFile,
  }) => PlatformRelease._(
    nextVersion: _HookModelDecoder.string(json, 'nextVersion'),
    changes: List<ConventionalChange>.unmodifiable(
      _HookModelDecoder.list(json, 'changes').map((value) {
        final change = _HookModelDecoder.object(value, 'change');
        return ConventionalChange(
          type: _HookModelDecoder.string(change, 'type'),
          scope: _HookModelDecoder.optionalString(change, 'scope'),
          description: _HookModelDecoder.string(change, 'description'),
          body: _HookModelDecoder.optionalString(change, 'body'),
        );
      }),
    ),
    storeReleaseNotes: StoreReleaseNotes._(
      file: storeReleaseNotesFile,
      platform: platform,
      version: _HookModelDecoder.string(json, 'nextVersion'),
    ),
  );

  /// Planned platform marketing version.
  final String nextVersion;

  /// Changes included in the platform release.
  final List<ConventionalChange> changes;

  /// Writer for this version's localized store release notes.
  final StoreReleaseNotes storeReleaseNotes;
}

/// Nullable platform releases exposed before SMF creates a release pull
/// request.
final class PlannedReleases {
  const PlannedReleases({required this.ios, required this.android});

  /// Planned iOS release, or `null` when iOS is not being released.
  final PlatformRelease? ios;

  /// Planned Android release, or `null` when Android is not being released.
  final PlatformRelease? android;
}

/// Writes localized store notes for one planned platform release.
final class StoreReleaseNotes {
  const StoreReleaseNotes._({
    required File file,
    required HookReleasePlatform platform,
    required String version,
  }) : _file = file,
       _platform = platform,
       _version = version;

  final File _file;
  final HookReleasePlatform _platform;
  final String _version;

  /// Maximum number of characters accepted by this platform's store.
  int get characterLimit => _platform.characterLimit;

  /// Writes one localized [message] for this platform release.
  ///
  /// Existing platforms, versions, and locales are preserved.
  void write({
    required String locale,
    required String message,
  }) {
    final normalizedLocale = locale.trim();
    if (normalizedLocale.isEmpty) {
      throw const FormatException('Store release note locale cannot be empty.');
    }
    if (message.trim().isEmpty) {
      throw const FormatException(
        'Store release note message cannot be empty.',
      );
    }
    if (message.length > characterLimit) {
      throw FormatException(
        '${_platform.name} store release note for $normalizedLocale must be at most '
        '$characterLimit characters.',
      );
    }
    final root = _file.existsSync()
        ? _HookModelDecoder.object(
            jsonDecode(_file.readAsStringSync()),
            'store release notes',
          )
        : <String, Object?>{};
    final platformNotes = _HookModelDecoder.optionalObject(
      root[_platform.name],
      _platform.name,
    );
    final versionNotes = _HookModelDecoder.optionalObject(
      platformNotes[_version],
      '${_platform.name}.$_version',
    );
    versionNotes[normalizedLocale] = message;
    platformNotes[_version] = versionNotes;
    root[_platform.name] = platformNotes;

    _file.parent.createSync(recursive: true);
    _file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(root)}\n',
    );
  }
}

final class _HookModelDecoder {
  const _HookModelDecoder._();

  static Map<String, Object?> optionalObject(Object? value, String path) =>
      value == null ? <String, Object?>{} : object(value, path);

  static Map<String, Object?> object(Object? value, String name) {
    if (value is! Map<Object?, Object?>) {
      throw FormatException('$name must be an object.');
    }
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw FormatException('$name must contain only string keys.');
      }
      result[key] = entry.value;
    }
    return result;
  }

  static String string(Map<String, Object?> json, String name) {
    final value = json[name];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$name must be a non-empty string.');
    }
    return value;
  }

  static String? optionalString(Map<String, Object?> json, String name) {
    final value = json[name];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$name must be a non-empty string when provided.');
    }
    return value;
  }

  static List<Object?> list(Map<String, Object?> json, String name) {
    final value = json[name];
    if (value is! List<Object?>) {
      throw FormatException('$name must be a list.');
    }
    return value;
  }
}
