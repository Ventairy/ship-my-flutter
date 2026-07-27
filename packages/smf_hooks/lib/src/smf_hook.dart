import 'dart:convert';
import 'dart:io' as io;

import 'package:pub_semver/pub_semver.dart';

import 'models.dart';

/// Repository hook phases supported by SMF.
enum SmfHookPhase {
  beforeCreatePr('before_create_pr'),
  beforeBuild('before_build');

  const SmfHookPhase(this.value);

  /// Stable protocol value used by the hook runner.
  final String value;

  /// Parses one stable hook phase value.
  static SmfHookPhase parse(String value) => switch (value) {
    'before_create_pr' => SmfHookPhase.beforeCreatePr,
    'before_build' => SmfHookPhase.beforeBuild,
    _ => throw FormatException('Unsupported SMF hook phase "$value".'),
  };
}

/// Typed non-secret context shared by every repository hook.
sealed class SmfHookContext {
  const SmfHookContext({
    required this.phase,
    required this.platform,
    required this.platformVersion,
    required this.repositoryRoot,
    required this.appRoot,
    required this.smfDirectory,
    required this.configFile,
    required this.changelogFile,
    required this.storeReleaseNotesFile,
    required this.flavor,
  });

  /// Hook phase being executed.
  final SmfHookPhase phase;

  /// Platform being released.
  final Platform platform;

  /// Planned platform marketing version.
  final Version platformVersion;

  /// Git repository containing the app.
  final io.Directory repositoryRoot;

  /// Flutter app that owns the discovered `smf` directory.
  final io.Directory appRoot;

  /// Directory containing SMF configuration and release state.
  final io.Directory smfDirectory;

  /// User-authored YAML configuration.
  final io.File configFile;

  /// Machine-owned changelog file.
  final io.File changelogFile;

  /// Optional user-owned localized store notes file.
  final io.File storeReleaseNotesFile;

  /// Configured Flutter flavor, when present.
  final String? flavor;
}

/// Context supplied before SMF creates or updates a release pull request.
final class SmfBeforeCreatePrContext extends SmfHookContext {
  const SmfBeforeCreatePrContext({
    required super.platform,
    required super.platformVersion,
    required super.repositoryRoot,
    required super.appRoot,
    required super.smfDirectory,
    required super.configFile,
    required super.changelogFile,
    required super.storeReleaseNotesFile,
    required super.flavor,
    required this.currentPlatformVersion,
    required this.releasePlan,
  }) : super(phase: SmfHookPhase.beforeCreatePr);

  /// Platform version before the planned bump.
  final Version currentPlatformVersion;

  /// Complete version and changelog plan about to enter the pull request.
  final ReleasePlan releasePlan;
}

/// Context supplied before SMF fingerprints and builds an iOS candidate.
final class SmfBeforeBuildContext extends SmfHookContext {
  const SmfBeforeBuildContext({
    required super.platform,
    required super.platformVersion,
    required super.repositoryRoot,
    required super.appRoot,
    required super.smfDirectory,
    required super.configFile,
    required super.changelogFile,
    required super.storeReleaseNotesFile,
    required super.flavor,
    required this.release,
  }) : super(phase: SmfHookPhase.beforeBuild);

  /// Changelog release that the candidate implements.
  final ChangelogRelease release;
}

/// Base class for a typed repository hook.
///
/// Implement [run] in `smf/hooks/before_create_pr.dart` or
/// `smf/hooks/before_build.dart`, then call [runSmfHook] from `main`.
abstract class SmfHook {
  const SmfHook();

  /// Whether SMF commits every tracked or unignored change left by the hook.
  ///
  /// Override with `false` only when the hook commits its own changes or leaves
  /// a clean worktree.
  bool get commitChanges => true;

  /// Executes repository-owned preparation with a phase-specific context.
  Future<void> run(covariant SmfHookContext context);
}

/// Loads the private hook protocol, runs [hook], and reports its result.
///
/// Hook entrypoints normally call this without [environment]. SMF supplies the
/// protocol paths and strips Apple and GitHub credentials before execution.
Future<void> runSmfHook(
  SmfHook hook, {
  Map<String, String>? environment,
}) async {
  final values = environment ?? io.Platform.environment;
  final contextPath = _requiredEnvironment(values, 'SMF_HOOK_CONTEXT_PATH');
  final resultPath = _requiredEnvironment(values, 'SMF_HOOK_RESULT_PATH');
  final context = await _readContext(contextPath);
  await hook.run(context);
  await writeJson(resultPath, <String, Object?>{
    'schemaVersion': 1,
    'commitChanges': hook.commitChanges,
  });
}

Future<SmfHookContext> _readContext(String path) async {
  try {
    final value = await readJson(path);
    final json = _object(value, 'hook context');
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != 1) {
      throw FormatException(
        'Unsupported SMF hook schema version "$schemaVersion".',
      );
    }
    final phase = SmfHookPhase.parse(_string(json, 'phase'));
    final platform = Platform.parse(_string(json, 'platform'));
    final platformVersion = Version.parse(_string(json, 'platformVersion'));
    final common = (
      platform: platform,
      platformVersion: platformVersion,
      repositoryRoot: io.Directory(_string(json, 'repositoryRoot')),
      appRoot: io.Directory(_string(json, 'appRoot')),
      smfDirectory: io.Directory(_string(json, 'smfDirectory')),
      configFile: io.File(_string(json, 'configFile')),
      changelogFile: io.File(_string(json, 'changelogFile')),
      storeReleaseNotesFile: io.File(_string(json, 'storeReleaseNotesFile')),
      flavor: _optionalString(json, 'flavor'),
    );
    return switch (phase) {
      SmfHookPhase.beforeCreatePr => SmfBeforeCreatePrContext(
        platform: common.platform,
        platformVersion: common.platformVersion,
        repositoryRoot: common.repositoryRoot,
        appRoot: common.appRoot,
        smfDirectory: common.smfDirectory,
        configFile: common.configFile,
        changelogFile: common.changelogFile,
        storeReleaseNotesFile: common.storeReleaseNotesFile,
        flavor: common.flavor,
        currentPlatformVersion: Version.parse(
          _string(json, 'currentPlatformVersion'),
        ),
        releasePlan: ReleasePlan.fromJson(
          _object(json['releasePlan'], 'releasePlan'),
        ),
      ),
      SmfHookPhase.beforeBuild => SmfBeforeBuildContext(
        platform: common.platform,
        platformVersion: common.platformVersion,
        repositoryRoot: common.repositoryRoot,
        appRoot: common.appRoot,
        smfDirectory: common.smfDirectory,
        configFile: common.configFile,
        changelogFile: common.changelogFile,
        storeReleaseNotesFile: common.storeReleaseNotesFile,
        flavor: common.flavor,
        release: ChangelogRelease.fromJson(_object(json['release'], 'release')),
      ),
    };
  } on Object catch (error) {
    throw FormatException('The SMF hook context is invalid: $error');
  }
}

String _requiredEnvironment(Map<String, String> environment, String name) {
  final value = environment[name]?.trim();
  if (value == null || value.isEmpty) {
    throw StateError('$name is required when running an SMF hook.');
  }
  return value;
}

Future<Object?> readJson(String path) async =>
    jsonDecode(await io.File(path).readAsString());

Future<void> writeJson(String path, Object? value) async {
  final file = io.File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(value)}\n',
  );
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
