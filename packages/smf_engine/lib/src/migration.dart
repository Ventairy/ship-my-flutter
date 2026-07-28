import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/dtos/candidate_receipt.dart';
import 'package:smf_engine/src/dtos/release_candidate_intent.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/models/smf_config.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/serialization.dart';
import 'package:smf_engine/src/templates.dart';

/// A user-selectable group of files owned by SMF migration.
enum MigrationTarget {
  /// User-authored `smf/config.yaml`.
  config('config'),

  /// Generated `.github/workflows/smf-<app-id>.yml`.
  githubActions('githubActions'),

  /// Machine-owned manifests, changelogs, notes, and candidate receipts.
  registry('registry');

  const MigrationTarget(this.value);

  /// Stable JSON representation used by the CLI.
  final String value;
}

/// Selects the repository and file groups for one migration.
final class MigrationOptions {
  /// Creates migration options.
  const MigrationOptions({
    required this.workingDirectory,
    this.smfPath,
    this.appId,
    this.config = false,
    this.githubActions = false,
    this.registry = false,
  });

  /// Directory from which SMF resolves the selected application.
  final String workingDirectory;

  /// Optional forward path to one `smf` directory.
  final String? smfPath;

  /// Optional stable app identity used when an older config cannot infer one.
  final String? appId;

  /// Whether to migrate configuration.
  final bool config;

  /// Whether to regenerate the GitHub Actions workflow.
  final bool githubActions;

  /// Whether to migrate the machine-owned release registry.
  final bool registry;

  Set<MigrationTarget> get _explicitTargets => <MigrationTarget>{
    if (config) MigrationTarget.config,
    if (githubActions) MigrationTarget.githubActions,
    if (registry) MigrationTarget.registry,
  };
}

/// Observable result of a completed repository migration.
final class MigrationResult {
  /// Creates a migration result.
  MigrationResult({
    required List<MigrationTarget> targets,
    required List<String> changedFiles,
  }) : targets = List<MigrationTarget>.unmodifiable(targets),
       changedFiles = List<String>.unmodifiable(changedFiles);

  /// File groups selected by the user or discovered for the default command.
  final List<MigrationTarget> targets;

  /// Repository-relative files whose contents changed.
  final List<String> changedFiles;

  /// Whether at least one file required migration.
  bool get migrated => changedFiles.isNotEmpty;

  /// Encodes the stable CLI result.
  Map<String, Object?> toJson() => <String, Object?>{
    'migrated': migrated,
    'targets': <String>[for (final target in targets) target.value],
    'changedFiles': changedFiles,
  };
}

final class _MigrationWrite {
  const _MigrationWrite(this.path, this.contents);

  final String path;
  final String? contents;
}

/// Migrates configuration, existing workflows, and machine-owned release state.
final class SmfMigration {
  const SmfMigration._();

  static const Map<int, String Function(String source, String appId)> _configMigrations =
      <int, String Function(String source, String appId)>{};

  /// Migrates selected files without changing unrelated contents.
  ///
  /// With no explicit selector in [options], configuration and registry files
  /// are migrated, together with a managed workflow when one already exists.
  /// The operation validates all selected files before replacing any contents.
  static Future<MigrationResult> migrate(MigrationOptions options) async {
    final paths = SmfPaths.resolve(
      options.workingDirectory,
      smfPath: options.smfPath,
    );
    final explicitTargets = options._explicitTargets;
    final selectedTargets = explicitTargets.isNotEmpty
        ? explicitTargets
        : <MigrationTarget>{
            MigrationTarget.config,
            MigrationTarget.registry,
            if (await _managedWorkflowExists(paths, options.appId)) MigrationTarget.githubActions,
          };
    final targets = <MigrationTarget>[
      for (final target in MigrationTarget.values)
        if (selectedTargets.contains(target)) target,
    ];
    final writes = <_MigrationWrite>[];

    if (targets.contains(MigrationTarget.config)) {
      final write = await _planConfigMigration(paths, options.appId);
      if (write != null) writes.add(write);
    }
    if (targets.contains(MigrationTarget.githubActions)) {
      writes.addAll(
        await _planGitHubActionsMigration(paths, options.appId),
      );
    }
    if (targets.contains(MigrationTarget.registry)) {
      writes.addAll(await _planRegistryMigration(paths));
    }

    for (final write in writes) {
      await _writeAtomically(paths.repositoryRoot, write);
    }
    return MigrationResult(
      targets: targets,
      changedFiles: <String>[
        for (final write in writes) p.relative(write.path, from: paths.repositoryRoot).replaceAll(r'\', '/'),
      ],
    );
  }

  static Future<_MigrationWrite?> _planConfigMigration(
    SmfPaths paths,
    String? explicitAppId,
  ) async {
    await _rejectSymbolicLink(paths.config);
    final original = await File(paths.config).readAsString();
    var source = original;
    var value = _parseConfigMap(source, paths.config);
    var schemaVersion = _configSchemaVersion(value);
    if (schemaVersion > SmfConfig.currentSchemaVersion) {
      throw const SmfError(
        'smf/config.yaml was created by a newer SMF version.',
        'CONFIG_MIGRATION_NEWER_VERSION',
      );
    }
    while (schemaVersion < SmfConfig.currentSchemaVersion) {
      final migration = _configMigrations[schemaVersion];
      if (migration == null) {
        throw SmfError(
          'No configuration migration is available from schema_version '
              '$schemaVersion to ${schemaVersion + 1}.',
          'CONFIG_MIGRATION_UNAVAILABLE',
        );
      }
      source = migration(
        source,
        await _appIdForMigration(paths, explicitAppId, value),
      );
      value = _parseConfigMap(source, paths.config);
      final nextVersion = _configSchemaVersion(value);
      SmfError.check(
        nextVersion == schemaVersion + 1,
        'Configuration migration $schemaVersion must produce schema_version '
            '${schemaVersion + 1}.',
        'CONFIG_MIGRATION_INVALID',
      );
      schemaVersion = nextVersion;
    }
    source = _updateConfigSchemaHint(source);
    SmfState.parseConfig(value, source: paths.config);
    return source == original ? null : _MigrationWrite(paths.config, source);
  }

  static String _updateConfigSchemaHint(String source) {
    final hint = RegExp(
      r'^# yaml-language-server: \$schema=\S+[ \t]*$',
      multiLine: true,
    );
    if (!hint.hasMatch(source)) return source;
    return source.replaceFirst(
      hint,
      '# yaml-language-server: \$schema=${SmfTemplates.configSchemaUrl}',
    );
  }

  static Future<String> _appIdForMigration(
    SmfPaths paths,
    String? explicitAppId,
    Map<String, Object?> config,
  ) async {
    final configured = config['app_id'];
    if (configured is String && explicitAppId != null && explicitAppId != configured) {
      throw SmfError(
        '--app-id "$explicitAppId" does not match configured app_id '
            '"$configured".',
        'APP_ID_MISMATCH',
      );
    }
    final candidate = explicitAppId ?? (configured is String ? configured : null);
    if (candidate != null) {
      final appId = _validateMigrationAppId(candidate);
      await _ensureUniqueMigrationAppId(paths, appId);
      return appId;
    }

    final pubspec = await SmfFileSystem.readYaml(
      p.join(paths.appRoot, 'pubspec.yaml'),
    );
    final name = pubspec is Map<String, Object?> ? pubspec['name'] : null;
    if (name is String && name.trim().isNotEmpty) {
      final appId = _validateMigrationAppId(name.trim());
      await _ensureUniqueMigrationAppId(paths, appId);
      return appId;
    }
    throw const SmfError(
      'Could not infer app_id from pubspec.yaml. Pass --app-id.',
      'APP_ID_NOT_FOUND',
    );
  }

  static Future<void> _ensureUniqueMigrationAppId(
    SmfPaths paths,
    String appId,
  ) async {
    for (final directory in SmfPaths.discover(paths.repositoryRoot)) {
      if (p.equals(directory, paths.directory)) continue;
      final value = await SmfFileSystem.readYaml(
        p.join(directory, SmfPaths.configFileName),
      );
      final otherAppId = value is Map<String, Object?> ? value['app_id'] : null;
      if (otherAppId == appId) {
        throw SmfError(
          'app_id "$appId" is already used by '
              '${p.relative(p.dirname(directory), from: paths.repositoryRoot)}.',
          'APP_ID_CONFLICT',
        );
      }
    }
  }

  static String _validateMigrationAppId(String value) {
    if (!RegExp(r'^[a-z0-9][a-z0-9_-]*$').hasMatch(value)) {
      throw SmfError(
        '$value is not a valid app ID. Use lowercase letters, numbers, '
            'underscores, or hyphens.',
        'INVALID_APP_ID',
      );
    }
    return value;
  }

  static Map<String, Object?> _parseConfigMap(String source, String path) {
    try {
      final value = SmfFileSystem.parseYaml(
        source,
        sourceUrl: Uri.file(path),
      );
      if (value is! Map<String, Object?>) {
        throw const SmfError(
          'smf/config.yaml must contain a YAML object before it can be migrated.',
          'CONFIG_MIGRATION_INVALID',
        );
      }
      return value;
    } on FormatException catch (error) {
      throw SmfError(
        '$path contains malformed YAML.',
        'CONFIG_MIGRATION_INVALID',
        cause: error,
      );
    }
  }

  static int _configSchemaVersion(Map<String, Object?> value) {
    final schemaVersion = value['schema_version'];
    if (schemaVersion is! int || schemaVersion < 0) {
      throw const SmfError(
        'smf/config.yaml schema_version must be a non-negative integer.',
        'CONFIG_MIGRATION_INVALID',
      );
    }
    return schemaVersion;
  }

  static Future<List<_MigrationWrite>> _planGitHubActionsMigration(
    SmfPaths paths,
    String? explicitAppId,
  ) async {
    final configValue = _parseConfigMap(
      await File(paths.config).readAsString(),
      paths.config,
    );
    final appId = await _appIdForMigration(
      paths,
      explicitAppId,
      configValue,
    );
    final workflowPath = p.join(
      paths.repositoryRoot,
      '.github',
      'workflows',
      SmfTemplates.workflowFileName(appId),
    );
    await _ensureSafePath(paths.repositoryRoot, workflowPath);
    final smfPath = p.relative(paths.directory, from: paths.repositoryRoot).replaceAll(r'\', '/');
    final contents = SmfTemplates.workflowYaml(smfPath: smfPath, appId: appId);
    final writes = <_MigrationWrite>[];
    if (!(await SmfFileSystem.exists(workflowPath)) || await File(workflowPath).readAsString() != contents) {
      writes.add(_MigrationWrite(workflowPath, contents));
    }
    final legacyWorkflowPath = p.join(
      paths.repositoryRoot,
      '.github',
      'workflows',
      'smf.yml',
    );
    if (!p.equals(legacyWorkflowPath, workflowPath) && await SmfFileSystem.exists(legacyWorkflowPath)) {
      await _ensureSafePath(paths.repositoryRoot, legacyWorkflowPath);
      writes.add(_MigrationWrite(legacyWorkflowPath, null));
    }
    return writes;
  }

  static Future<bool> _managedWorkflowExists(
    SmfPaths paths,
    String? explicitAppId,
  ) async {
    final legacyWorkflowPath = p.join(
      paths.repositoryRoot,
      '.github',
      'workflows',
      'smf.yml',
    );
    if (await SmfFileSystem.exists(legacyWorkflowPath)) return true;
    final configValue = _parseConfigMap(
      await File(paths.config).readAsString(),
      paths.config,
    );
    final appId = await _appIdForMigration(
      paths,
      explicitAppId,
      configValue,
    );
    return SmfFileSystem.exists(
      p.join(
        paths.repositoryRoot,
        '.github',
        'workflows',
        SmfTemplates.workflowFileName(appId),
      ),
    );
  }

  static Future<List<_MigrationWrite>> _planRegistryMigration(SmfPaths paths) async {
    final writes = <_MigrationWrite>[];
    for (final path in <String>[
      paths.manifest,
      paths.changelog,
      paths.storeReleaseNotes,
      paths.candidates,
    ]) {
      if (await SmfFileSystem.exists(path)) await _rejectSymbolicLink(path);
    }

    if (await SmfFileSystem.exists(paths.manifest)) {
      final value = await _readRegistryJson(paths.manifest);
      final manifest = SmfState.parseManifest(value, source: paths.manifest);
      if (!_hasPlatform(value, 'android')) {
        writes.add(_MigrationWrite(paths.manifest, _json(manifest.toJson())));
      }
    }
    if (await SmfFileSystem.exists(paths.changelog)) {
      final value = await _readRegistryJson(paths.changelog);
      final changelog = SmfState.parseChangelog(value, source: paths.changelog);
      if (!_hasPlatform(value, 'android')) {
        writes.add(_MigrationWrite(paths.changelog, _json(changelog.toJson())));
      }
    }
    if (await SmfFileSystem.exists(paths.storeReleaseNotes)) {
      SmfState.parseStoreReleaseNotes(
        await _readRegistryJson(paths.storeReleaseNotes),
        source: paths.storeReleaseNotes,
      );
    }
    if (await Directory(paths.candidates).exists()) {
      final entries = await Directory(
        paths.candidates,
      ).list(followLinks: false).toList();
      entries.sort((left, right) => left.path.compareTo(right.path));
      for (final entry in entries) {
        if (p.extension(entry.path) != '.json') continue;
        await _rejectSymbolicLink(entry.path);
        if (entry is! File) {
          throw SmfError(
            '${entry.path} must be a regular candidate receipt file.',
            'REGISTRY_MIGRATION_INVALID',
          );
        }
        final value = await _readRegistryJson(entry.path);
        if (p.basename(entry.path).endsWith('.intent.json')) {
          ReleaseCandidateIntent.fromJson(value, source: entry.path);
          continue;
        }
        final receipt = CandidateReceipt.fromJson(value, source: entry.path);
        if (_schemaVersion(value) == 1) {
          writes.add(_MigrationWrite(entry.path, _json(receipt.toJson())));
        }
      }
    }
    return writes;
  }

  static Future<Object?> _readRegistryJson(String path) async {
    try {
      return await SmfFileSystem.readJson(path);
    } on FormatException catch (error) {
      throw SmfError(
        '$path contains malformed JSON.',
        'REGISTRY_MIGRATION_INVALID',
        cause: error,
      );
    }
  }

  static bool _hasPlatform(Object? value, String platform) {
    if (value is! Map<Object?, Object?>) return false;
    final platforms = value['platforms'];
    return platforms is Map<Object?, Object?> && platforms.containsKey(platform);
  }

  static Object? _schemaVersion(Object? value) => value is Map<Object?, Object?> ? value['schemaVersion'] : null;

  static String _json(Object? value) => '${const JsonEncoder.withIndent('  ').convert(value)}\n';

  static Future<void> _ensureSafePath(String repositoryRoot, String path) async {
    SmfError.check(
      p.isWithin(repositoryRoot, path),
      'Migration target escapes the repository: $path.',
      'MIGRATION_PATH_ESCAPE',
    );
    var current = path;
    while (!p.equals(current, repositoryRoot)) {
      await _rejectSymbolicLink(current);
      current = p.dirname(current);
    }
  }

  static Future<void> _rejectSymbolicLink(String path) async {
    if (await FileSystemEntity.type(path, followLinks: false) == FileSystemEntityType.link) {
      throw SmfError(
        'Migration refuses to read or replace symbolic link: $path.',
        'MIGRATION_PATH_SYMLINK',
      );
    }
  }

  static Future<void> _writeAtomically(
    String repositoryRoot,
    _MigrationWrite write,
  ) async {
    await _ensureSafePath(repositoryRoot, write.path);
    final target = File(write.path);
    final contents = write.contents;
    if (contents == null) {
      if (await target.exists()) await target.delete();
      return;
    }
    await target.parent.create(recursive: true);
    final temporary = File(
      '${write.path}.smf-migrate-$pid-'
      '${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    final backup = File('${temporary.path}.backup');
    try {
      await temporary.writeAsString(contents);
      if (await target.exists()) await target.rename(backup.path);
      try {
        await temporary.rename(write.path);
      } on Object {
        if (await backup.exists()) await backup.rename(write.path);
        rethrow;
      }
      if (await backup.exists()) await backup.delete();
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
