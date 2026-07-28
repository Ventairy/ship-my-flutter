import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/serialization.dart';
import 'package:yaml/yaml.dart';

/// Reads and validates all persisted state for one SMF application.
final class SmfState {
  const SmfState._();

  /// Reads the application configuration.
  static Future<SmfConfig> config([String? root]) {
    return _SmfStateFiles.loadConfig(root);
  }

  /// Reads generated platform release state.
  static Future<SmfManifest> manifest([String? root]) {
    return _SmfStateFiles.loadManifest(root);
  }

  /// Reads generated platform changelog state.
  static Future<ChangelogManifest> changelog([String? root]) {
    return _SmfStateFiles.loadChangelog(root);
  }

  /// Reads optional localized store release notes.
  static Future<StoreReleaseNotes> storeReleaseNotes([String? root]) {
    return _SmfStateFiles.loadStoreReleaseNotes(root);
  }

  /// Parses and validates application configuration.
  static SmfConfig parseConfig(
    Object? value, {
    String source = 'configuration',
  }) {
    return _SmfStateFiles.validateConfig(value, source: source);
  }

  /// Parses and validates generated platform release state.
  static SmfManifest parseManifest(
    Object? value, {
    String source = 'manifest',
  }) {
    return _SmfStateFiles.validateManifest(value, source: source);
  }

  /// Parses and validates generated changelog state.
  static ChangelogManifest parseChangelog(
    Object? value, {
    String source = 'changelog',
  }) {
    return _SmfStateFiles.validateChangelog(value, source: source);
  }

  /// Parses and validates localized store release notes.
  static StoreReleaseNotes parseStoreReleaseNotes(
    Object? value, {
    String source = 'store release notes',
  }) {
    return _SmfStateFiles.validateStoreReleaseNotes(value, source: source);
  }
}

final class _SmfStateFiles {
  const _SmfStateFiles._();

  static const Set<String> _rootConfigFields = <String>{
    'schema_version',
    'app_id',
    'flavor',
    'target_branch',
    'release_trigger_paths',
    'platforms',
  };
  static const Set<String> _platformFields = <String>{'ios', 'android'};
  static const Set<String> _iosFields = <String>{
    'enabled',
    'initial_version',
    'bundle_id',
    'build_command',
    'ipa_output_path',
    'app_store',
  };
  static const Set<String> _appStoreFields = <String>{
    'release_candidate',
    'ship',
  };
  static const Set<String> _appleReleaseCandidateFields = <String>{
    'target',
    'groups',
    'wait_timeout_minutes',
  };
  static const Set<String> _appleShipFields = <String>{'target', 'groups'};
  static const Set<String> _androidFields = <String>{
    'enabled',
    'initial_version',
    'package_name',
    'build_command',
    'aab_output_path',
    'google_play',
  };
  static const Set<String> _googlePlayFields = <String>{
    'release_candidate',
    'ship',
  };
  static const Set<String> _googlePlayReleaseCandidateFields = <String>{
    'target',
    'tracks',
  };
  static const Set<String> _googlePlayShipFields = <String>{'target', 'tracks'};

  static Future<SmfConfig> loadConfig([String? root]) async {
    final paths = SmfPaths.resolve(root);
    try {
      return validateConfig(
        await SmfFileSystem.readYaml(paths.config),
        source: paths.config,
      );
    } on FileSystemException catch (error) {
      throw SmfError(
        'Could not read ${paths.config}: ${error.message}',
        'CONFIG_NOT_FOUND',
        cause: error,
      );
    } on YamlException catch (error) {
      throw SmfError(
        '${paths.config} is invalid:\n$error',
        'INVALID_CONFIG',
        cause: error,
      );
    }
  }

  /// Loads generated release state or derives the initial state without writing.
  ///
  /// Before the first release PR, the version comes from `initial_version` and
  /// the baseline comes from the commit that introduced `config.yaml`.
  static Future<SmfManifest> loadManifest([String? root]) async {
    final paths = SmfPaths.resolve(root);
    if (!(await SmfFileSystem.exists(paths.manifest))) {
      final config = await loadConfig(paths.directory);
      final baselineSha = await _initialBaselineSha(paths);
      return SmfManifest(
        ios: PlatformManifest(
          version: config.ios.initialVersion,
          baselineSha: baselineSha,
          pendingRelease: false,
        ),
        android: PlatformManifest(
          version: config.android.initialVersion,
          baselineSha: baselineSha,
          pendingRelease: false,
        ),
      );
    }
    return validateManifest(
      await _loadJson(paths.manifest),
      source: paths.manifest,
    );
  }

  /// Loads generated changelog state.
  ///
  /// Returns an empty history before the generated file exists.
  static Future<ChangelogManifest> loadChangelog([String? root]) async {
    final paths = SmfPaths.resolve(root);
    if (!(await SmfFileSystem.exists(paths.changelog))) {
      return const ChangelogManifest(
        iosReleases: <String, ChangelogRelease>{},
      );
    }
    return validateChangelog(
      await _loadJson(paths.changelog),
      source: paths.changelog,
    );
  }

  /// Loads optional localized notes, returning an empty map when no file exists.
  static Future<StoreReleaseNotes> loadStoreReleaseNotes([String? root]) async {
    final paths = SmfPaths.resolve(root);
    if (!(await SmfFileSystem.exists(paths.storeReleaseNotes))) {
      return const StoreReleaseNotes.empty();
    }
    return validateStoreReleaseNotes(
      await _loadJson(paths.storeReleaseNotes),
      source: paths.storeReleaseNotes,
    );
  }

  static Future<String> _initialBaselineSha(SmfPaths paths) async {
    final gitClient = GitClient(root: paths.repositoryRoot);
    final relativeConfig = p.relative(paths.config, from: paths.repositoryRoot).replaceAll(r'\', '/');
    final additions = await gitClient.run(<String>[
      'log',
      '--diff-filter=A',
      '--format=%H',
      '--reverse',
      '--',
      relativeConfig,
    ]);
    if (additions.isEmpty) return gitClient.currentSha();

    final introductionSha = additions.split('\n').first;
    final ancestry = await gitClient.run(<String>[
      'rev-list',
      '--parents',
      '-n',
      '1',
      introductionSha,
    ]);
    final commits = ancestry.split(RegExp(r'\s+'));
    return commits.length > 1 ? commits[1] : introductionSha;
  }

  static Future<Object?> _loadJson(String filePath) async {
    try {
      return await SmfFileSystem.readJson(filePath);
    } on FileSystemException catch (error) {
      throw SmfError(
        'Could not read $filePath: ${error.message}',
        'CONFIG_NOT_FOUND',
        cause: error,
      );
    } on FormatException catch (error) {
      throw SmfError(
        '$filePath is invalid:\n${error.message}',
        'INVALID_CONFIG',
        cause: error,
      );
    }
  }

  static SmfConfig validateConfig(Object? value, {String source = 'configuration'}) {
    try {
      final root = _objectMap(value, source);
      _configSchemaVersion(root, source);
      _rejectUnknownFields(root, _rootConfigFields, source);
      final platforms = _objectMap(root['platforms'], 'platforms');
      _rejectUnknownFields(platforms, _platformFields, 'platforms');
      final ios = _objectMap(
        platforms['ios'] ?? const <String, Object?>{},
        'platforms.ios',
      );
      final android = _objectMap(
        platforms['android'] ?? const <String, Object?>{},
        'platforms.android',
      );
      _rejectUnknownFields(ios, _iosFields, 'platforms.ios');
      _rejectUnknownFields(android, _androidFields, 'platforms.android');
      final config = SmfConfig(
        appId: _appId(root['app_id']),
        flavor: _optionalNonEmptyString(root['flavor'], 'flavor'),
        targetBranch: _nonEmptyString(
          root['target_branch'] ?? 'main',
          'target_branch',
        ),
        releaseTriggerPaths: _releaseTriggerPaths(
          root['release_trigger_paths'],
        ),
        ios: platforms.containsKey('ios') ? _parseIosConfig(ios) : const IosConfig(enabled: false),
        android: platforms.containsKey('android') ? _parseAndroidConfig(android) : const AndroidConfig(),
      );
      if (config.enabledPlatforms.isEmpty) {
        _fail('platforms must enable at least one supported platform');
      }
      return config;
    } on SmfError {
      rethrow;
    } on FormatException catch (error) {
      throw SmfError(
        '$source is invalid:\n${error.message}',
        'INVALID_CONFIG',
        cause: error,
      );
    }
  }

  static String _appId(Object? value) {
    final appId = _nonEmptyString(value, 'app_id');
    if (!RegExp(r'^[a-z0-9][a-z0-9_-]*$').hasMatch(appId)) {
      _fail(
        'app_id must start with a lowercase letter or number and contain only '
        'lowercase letters, numbers, underscores, or hyphens',
      );
    }
    return appId;
  }

  static List<String> _releaseTriggerPaths(Object? value) {
    if (value == null) return const <String>[];
    if (value is! List<Object?>) {
      _fail('release_trigger_paths must be a list');
    }
    final paths = <String>[];
    for (var index = 0; index < value.length; index++) {
      final path = _nonEmptyString(
        value[index],
        'release_trigger_paths[$index]',
      ).replaceAll(r'\', '/');
      if (p.isAbsolute(path) ||
          RegExp('^[A-Za-z]:/').hasMatch(path) ||
          path == '..' ||
          path.startsWith('../') ||
          path.contains('/../') ||
          path.endsWith('/..') ||
          path.contains('\n') ||
          path.contains('\r') ||
          path.contains('\u0000') ||
          path.startsWith(':')) {
        _fail(
          'release_trigger_paths[$index] must be a repository-relative path or '
          'glob that does not escape the repository',
        );
      }
      if (!paths.contains(path)) paths.add(path);
    }
    return List<String>.unmodifiable(paths);
  }

  static IosConfig _parseIosConfig(Map<String, Object?> ios) {
    final buildCommand = _optionalNonEmptyString(
      ios['build_command'],
      'platforms.ios.build_command',
    );
    if (buildCommand != null) {
      _validateBuildCommand(
        buildCommand,
        path: 'platforms.ios.build_command',
        managedFlags: const <String>[
          '--build-name',
          '--build-number',
          '--export-options-plist',
          '--flavor',
        ],
      );
    }
    final ipaOutputPath = _nonEmptyString(
      ios['ipa_output_path'] ?? 'build/ios/ipa',
      'platforms.ios.ipa_output_path',
    );
    _relativePath(ipaOutputPath, 'platforms.ios.ipa_output_path');
    final appStore = _objectMap(
      ios['app_store'] ?? const <String, Object?>{},
      'platforms.ios.app_store',
    );
    _rejectUnknownFields(appStore, _appStoreFields, 'platforms.ios.app_store');

    return IosConfig(
      enabled: _boolean(ios['enabled'] ?? true, 'platforms.ios.enabled'),
      initialVersion: _stableVersion(
        ios['initial_version'] ?? '0.0.0',
        'platforms.ios.initial_version',
      ),
      bundleId: _optionalNonEmptyString(
        ios['bundle_id'],
        'platforms.ios.bundle_id',
      ),
      buildCommand: buildCommand,
      ipaOutputPath: ipaOutputPath,
      appStore: _parseAppStoreConfig(appStore),
    );
  }

  static AndroidConfig _parseAndroidConfig(Map<String, Object?> android) {
    final buildCommand = _optionalNonEmptyString(
      android['build_command'],
      'platforms.android.build_command',
    );
    if (buildCommand != null) {
      _validateBuildCommand(
        buildCommand,
        path: 'platforms.android.build_command',
        managedFlags: const <String>[
          '--build-name',
          '--build-number',
          '--flavor',
        ],
      );
    }
    final aabOutputPath = _nonEmptyString(
      android['aab_output_path'] ?? 'build/app/outputs/bundle/release',
      'platforms.android.aab_output_path',
    );
    _relativePath(aabOutputPath, 'platforms.android.aab_output_path');
    final googlePlay = _objectMap(
      android['google_play'] ?? const <String, Object?>{},
      'platforms.android.google_play',
    );
    _rejectUnknownFields(
      googlePlay,
      _googlePlayFields,
      'platforms.android.google_play',
    );
    final packageName = _optionalNonEmptyString(
      android['package_name'],
      'platforms.android.package_name',
    );
    if (packageName != null &&
        !RegExp(
          r'^[A-Za-z][A-Za-z0-9_]*(?:\.[A-Za-z][A-Za-z0-9_]*)+$',
        ).hasMatch(packageName)) {
      _fail(
        'platforms.android.package_name must be a valid Android application ID',
      );
    }
    return AndroidConfig(
      enabled: _boolean(
        android['enabled'] ?? false,
        'platforms.android.enabled',
      ),
      initialVersion: _stableVersion(
        android['initial_version'] ?? '0.0.0',
        'platforms.android.initial_version',
      ),
      packageName: packageName,
      buildCommand: buildCommand,
      aabOutputPath: aabOutputPath,
      googlePlay: _parseGooglePlayConfig(googlePlay),
    );
  }

  static GooglePlayConfig _parseGooglePlayConfig(Map<String, Object?> googlePlay) {
    const candidatePath = 'platforms.android.google_play.release_candidate';
    final candidate = _objectMap(
      googlePlay['release_candidate'] ?? const <String, Object?>{},
      candidatePath,
    );
    _rejectUnknownFields(
      candidate,
      _googlePlayReleaseCandidateFields,
      candidatePath,
    );
    final candidateTarget = _googlePlayReleaseCandidateTarget(
      candidate['target'] ?? 'internal-testing',
      '$candidatePath.target',
    );
    final candidateTracks = _playTracks(
      candidate['tracks'],
      '$candidatePath.tracks',
    );
    _validatePlayTracks(
      candidateTarget == GooglePlayReleaseCandidateTarget.closedTesting,
      candidateTracks,
      candidatePath,
    );

    GooglePlayShipConfig? ship;
    if (googlePlay['ship'] != null) {
      const shipPath = 'platforms.android.google_play.ship';
      final value = _objectMap(googlePlay['ship'], shipPath);
      _rejectUnknownFields(value, _googlePlayShipFields, shipPath);
      final target = _googlePlayShipTarget(value['target'], '$shipPath.target');
      final tracks = _playTracks(value['tracks'], '$shipPath.tracks');
      _validatePlayTracks(
        target == GooglePlayShipTarget.closedTesting,
        tracks,
        shipPath,
      );
      ship = GooglePlayShipConfig(target: target, tracks: tracks);
    }

    return GooglePlayConfig(
      releaseCandidate: GooglePlayReleaseCandidateConfig(
        target: candidateTarget,
        tracks: candidateTracks,
      ),
      ship: ship,
    );
  }

  static GooglePlayReleaseCandidateTarget _googlePlayReleaseCandidateTarget(
    Object? value,
    String path,
  ) => switch (_nonEmptyString(value, path)) {
    'internal-testing' => GooglePlayReleaseCandidateTarget.internalTesting,
    'closed-testing' => GooglePlayReleaseCandidateTarget.closedTesting,
    'open-testing' => GooglePlayReleaseCandidateTarget.openTesting,
    final String invalid => _fail(
      '$path must be internal-testing, closed-testing, or open-testing, '
      'not "$invalid"',
    ),
  };

  static GooglePlayShipTarget _googlePlayShipTarget(Object? value, String path) =>
      switch (_nonEmptyString(value, path)) {
        'closed-testing' => GooglePlayShipTarget.closedTesting,
        'open-testing' => GooglePlayShipTarget.openTesting,
        'production' => GooglePlayShipTarget.production,
        final String invalid => _fail(
          '$path must be closed-testing, open-testing, or production, '
          'not "$invalid"',
        ),
      };

  static List<String> _playTracks(Object? value, String path) {
    final tracks = _stringList(
      value ?? const <Object?>[],
      path,
      nonEmpty: true,
    );
    for (final track in tracks) {
      if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(track)) {
        _fail('$path contains a track with unsupported characters');
      }
    }
    _requireUnique(tracks, path);
    return tracks;
  }

  static void _validatePlayTracks(bool closed, List<String> tracks, String path) {
    if (closed && tracks.isEmpty) {
      _fail('$path.tracks must contain at least one closed-testing track');
    }
    if (!closed && tracks.isNotEmpty) {
      _fail('$path.tracks is only supported when target is closed-testing');
    }
  }

  static void _validateBuildCommand(
    String command, {
    required String path,
    required List<String> managedFlags,
  }) {
    _validateSingleShellInvocation(command, path);
    for (final flag in managedFlags) {
      if (command.contains(flag)) {
        _fail(
          '$path must not set $flag because smf appends it automatically',
        );
      }
    }
  }

  static void _validateSingleShellInvocation(String command, String path) {
    String? quote;
    var escaped = false;
    for (var index = 0; index < command.length; index++) {
      final character = command[index];
      if (character == '\n' || character == '\r') {
        _invalidBuildCommandShape(path);
      }
      if (escaped) {
        escaped = false;
        continue;
      }
      if (quote == "'") {
        if (character == "'") quote = null;
        continue;
      }
      if (character == r'\') {
        escaped = true;
        continue;
      }
      if (quote == '"') {
        if (character == '`' || (character == r'$' && index + 1 < command.length && command[index + 1] == '(')) {
          _invalidBuildCommandShape(path);
        }
        if (character == '"') quote = null;
        continue;
      }
      if (character == "'" || character == '"') {
        quote = character;
        continue;
      }
      if (';&|<>()`'.contains(character)) {
        _invalidBuildCommandShape(path);
      }
      if (character == '#' && (index == 0 || _isShellWhitespace(command.codeUnitAt(index - 1)))) {
        _invalidBuildCommandShape(path);
      }
    }
    if (quote != null || escaped) {
      _fail('$path contains incomplete shell quoting');
    }
  }

  static bool _isShellWhitespace(int codeUnit) =>
      codeUnit == 0x20 || codeUnit == 0x09 || codeUnit == 0x0b || codeUnit == 0x0c;

  static Never _invalidBuildCommandShape(String path) => _fail(
    '$path must be one shell command invocation; '
    'put pipelines, chained commands, redirections, comments, and preparation '
    'steps in smf/hooks/before_build.dart',
  );

  static AppStoreConfig _parseAppStoreConfig(Map<String, Object?> appStore) {
    const candidatePath = 'platforms.ios.app_store.release_candidate';
    final candidate = _objectMap(
      appStore['release_candidate'] ?? const <String, Object?>{},
      candidatePath,
    );
    _rejectUnknownFields(candidate, _appleReleaseCandidateFields, candidatePath);
    final target = _appleReleaseCandidateTarget(
      candidate['target'] ?? 'internal-testing',
      '$candidatePath.target',
    );
    final groups = _groups(candidate['groups'], '$candidatePath.groups');
    final waitTimeoutMinutes = _integer(
      candidate['wait_timeout_minutes'] ?? 45,
      '$candidatePath.wait_timeout_minutes',
    );
    if (waitTimeoutMinutes < 5 || waitTimeoutMinutes > 180) {
      _fail(
        '$candidatePath.wait_timeout_minutes must be between 5 and 180',
      );
    }
    if (target == AppleReleaseCandidateTarget.externalTesting && groups.isEmpty) {
      _fail('$candidatePath.groups must contain at least one external group');
    }

    AppleShipConfig? ship;
    if (appStore['ship'] != null) {
      const shipPath = 'platforms.ios.app_store.ship';
      final value = _objectMap(appStore['ship'], shipPath);
      _rejectUnknownFields(value, _appleShipFields, shipPath);
      final shipTarget = _appleShipTarget(
        value['target'],
        '$shipPath.target',
      );
      final shipGroups = _groups(value['groups'], '$shipPath.groups');
      if (shipTarget == AppleShipTarget.externalTesting && shipGroups.isEmpty) {
        _fail('$shipPath.groups must contain at least one external group');
      }
      if (shipTarget != AppleShipTarget.externalTesting && shipGroups.isNotEmpty) {
        _fail(
          '$shipPath.groups is only supported when target is external-testing',
        );
      }
      ship = AppleShipConfig(target: shipTarget, groups: shipGroups);
    }

    return AppStoreConfig(
      releaseCandidate: AppleReleaseCandidateConfig(
        target: target,
        groups: groups,
        waitTimeoutMinutes: waitTimeoutMinutes,
      ),
      ship: ship,
    );
  }

  static AppleReleaseCandidateTarget _appleReleaseCandidateTarget(
    Object? value,
    String path,
  ) => switch (_nonEmptyString(value, path)) {
    'internal-testing' => AppleReleaseCandidateTarget.internalTesting,
    'external-testing' => AppleReleaseCandidateTarget.externalTesting,
    final String invalid => _fail(
      '$path must be internal-testing or external-testing, not "$invalid"',
    ),
  };

  static AppleShipTarget _appleShipTarget(Object? value, String path) => switch (_nonEmptyString(value, path)) {
    'external-testing' => AppleShipTarget.externalTesting,
    'submit-for-review' => AppleShipTarget.submitForReview,
    'production' => AppleShipTarget.production,
    final String invalid => _fail(
      '$path must be external-testing, submit-for-review, or production, '
      'not "$invalid"',
    ),
  };

  static List<String> _groups(Object? value, String path) {
    final groups = _stringList(
      value ?? const <Object?>[],
      path,
      nonEmpty: true,
    );
    _requireUnique(groups, path);
    return groups;
  }

  static void _requireUnique(List<String> values, String path) {
    if (values.toSet().length != values.length) {
      _fail('$path must not contain duplicate values');
    }
  }

  static SmfManifest validateManifest(Object? value, {String source = 'manifest'}) {
    try {
      final root = _objectMap(value, source);
      _schemaVersion(root, source);
      final platforms = _objectMap(root['platforms'], 'platforms');
      final ios = _objectMap(platforms['ios'], 'platforms.ios');
      final android = platforms['android'] == null
          ? <String, Object?>{
              'version': '0.0.0',
              'baselineSha': ios['baselineSha'],
              'pendingRelease': false,
            }
          : _objectMap(platforms['android'], 'platforms.android');
      return SmfManifest(
        ios: _parsePlatformManifest(ios, 'platforms.ios'),
        android: _parsePlatformManifest(android, 'platforms.android'),
      );
    } on SmfError {
      rethrow;
    } on FormatException catch (error) {
      throw SmfError(
        '$source is invalid:\n${error.message}',
        'INVALID_CONFIG',
        cause: error,
      );
    }
  }

  static PlatformManifest _parsePlatformManifest(
    Map<String, Object?> value,
    String path,
  ) => PlatformManifest(
    version: _stableVersion(value['version'], '$path.version'),
    baselineSha: _gitSha(value['baselineSha'], '$path.baselineSha'),
    pendingRelease: _boolean(value['pendingRelease'], '$path.pendingRelease'),
  );

  static ChangelogManifest validateChangelog(
    Object? value, {
    String source = 'changelog',
  }) {
    try {
      final root = _objectMap(value, source);
      _schemaVersion(root, source);
      final platforms = _objectMap(root['platforms'], 'platforms');
      final ios = _parsePlatformReleases(platforms, Platform.ios);
      final android = _parsePlatformReleases(platforms, Platform.android);
      return ChangelogManifest(iosReleases: ios, androidReleases: android);
    } on SmfError {
      rethrow;
    } on FormatException catch (error) {
      throw SmfError(
        '$source is invalid:\n${error.message}',
        'INVALID_CONFIG',
        cause: error,
      );
    }
  }

  static Map<String, ChangelogRelease> _parsePlatformReleases(
    Map<String, Object?> platforms,
    Platform platform,
  ) {
    if (platforms[platform.value] == null) {
      return <String, ChangelogRelease>{};
    }
    final prefix = 'platforms.${platform.value}';
    final value = _objectMap(platforms[platform.value], prefix);
    final releases = _objectMap(value['releases'], '$prefix.releases');
    final parsed = <String, ChangelogRelease>{};
    for (final entry in releases.entries) {
      final release = _objectMap(
        entry.value,
        '$prefix.releases.${entry.key}',
      );
      final version = _stableVersion(
        release['version'],
        '$prefix.releases.${entry.key}.version',
      );
      if (version != entry.key) {
        _fail(
          '$prefix.releases.${entry.key}.version must match its release key '
          '${entry.key}',
        );
      }
      final changesValue = release['changes'];
      if (changesValue is! List<Object?> || changesValue.isEmpty) {
        _fail(
          '$prefix.releases.${entry.key}.changes must contain at least one '
          'change',
        );
      }
      final changes = <ConventionalChange>[
        for (var index = 0; index < changesValue.length; index++)
          _parseChange(
            changesValue[index],
            '$prefix.releases.${entry.key}.changes.$index',
          ),
      ];
      parsed[entry.key] = ChangelogRelease(
        version: version,
        preparedAt: _dateTime(
          release['preparedAt'],
          '$prefix.releases.${entry.key}.preparedAt',
        ),
        baseSha: _gitSha(
          release['baseSha'],
          '$prefix.releases.${entry.key}.baseSha',
        ),
        headSha: _gitSha(
          release['headSha'],
          '$prefix.releases.${entry.key}.headSha',
        ),
        changes: changes,
      );
    }
    return parsed;
  }

  static StoreReleaseNotes validateStoreReleaseNotes(
    Object? value, {
    String source = 'store release notes',
  }) {
    try {
      final root = _objectMap(value, source);
      final result = <Platform, Map<String, Map<String, String>>>{};
      for (final entry in root.entries) {
        final platform = Platform.parse(entry.key);
        final versions = _objectMap(entry.value, entry.key);
        result[platform] = <String, Map<String, String>>{
          for (final version in versions.entries)
            version.key: <String, String>{
              for (final locale in _objectMap(
                version.value,
                '${entry.key}.${version.key}',
              ).entries)
                locale.key: _boundedNote(
                  locale.value,
                  '${entry.key}.${version.key}.${locale.key}',
                  platform,
                ),
            },
        };
      }
      return StoreReleaseNotes(values: result);
    } on SmfError {
      rethrow;
    } on FormatException catch (error) {
      throw SmfError(
        '$source is invalid:\n${error.message}',
        'INVALID_CONFIG',
        cause: error,
      );
    }
  }

  static ConventionalChange _parseChange(Object? value, String path) {
    final change = _objectMap(value, path);
    final platformsValue = change['platforms'];
    if (platformsValue is! List<Object?>) {
      _fail('$path.platforms must be a list');
    }
    return ConventionalChange(
      sha: _gitSha(change['sha'], '$path.sha'),
      type: _nonEmptyString(change['type'], '$path.type'),
      scope: _nullableString(change['scope'], '$path.scope'),
      description: _nonEmptyString(change['description'], '$path.description'),
      body: _nullableString(change['body'], '$path.body'),
      breaking: _boolean(change['breaking'], '$path.breaking'),
      versionBump: VersionBump.maybeParse(change['versionBump']),
      platforms: platformsValue
          .map(
            (item) => Platform.parse(_nonEmptyString(item, '$path.platforms')),
          )
          .toList(),
    );
  }

  static void _schemaVersion(Map<String, Object?> value, String source) {
    if (value['schemaVersion'] != 1) {
      _fail('$source.schemaVersion must be 1');
    }
  }

  static void _configSchemaVersion(Map<String, Object?> value, String source) {
    if (value['schema_version'] != 3) {
      _fail('$source.schema_version must be 3; run smf migrate');
    }
  }

  static Map<String, Object?> _objectMap(Object? value, String path) {
    if (value is! Map<Object?, Object?>) {
      _fail('$path must be an object');
    }
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        _fail('$path keys must be strings');
      }
      result[key] = entry.value;
    }
    return result;
  }

  static void _rejectUnknownFields(
    Map<String, Object?> value,
    Set<String> allowed,
    String path,
  ) {
    for (final field in value.keys) {
      if (!allowed.contains(field)) {
        _fail('$path contains unknown field "$field"');
      }
    }
  }

  static String _nonEmptyString(Object? value, String path) {
    if (value is! String || value.isEmpty) {
      _fail('$path must be a non-empty string');
    }
    return value;
  }

  static String? _optionalNonEmptyString(Object? value, String path) =>
      value == null ? null : _nonEmptyString(value, path);

  static String? _nullableString(Object? value, String path) {
    if (value == null) return null;
    if (value is! String) _fail('$path must be a string or null');
    return value;
  }

  static bool _boolean(Object? value, String path) {
    if (value is! bool) _fail('$path must be a boolean');
    return value;
  }

  static int _integer(Object? value, String path) {
    if (value is! int) _fail('$path must be an integer');
    return value;
  }

  static List<String> _stringList(Object? value, String path, {bool nonEmpty = false}) {
    if (value is! List<Object?>) _fail('$path must be a list');
    return <String>[
      for (var index = 0; index < value.length; index++)
        nonEmpty ? _nonEmptyString(value[index], '$path.$index') : _string(value[index], '$path.$index'),
    ];
  }

  static String _string(Object? value, String path) {
    if (value is! String) _fail('$path must be a string');
    return value;
  }

  static void _relativePath(String value, String path) {
    if (p.isAbsolute(value) || p.posix.isAbsolute(value) || p.windows.isAbsolute(value)) {
      _fail('$path must be a relative path');
    }
    if (value.split(RegExp(r'[/\\]')).contains('..')) {
      _fail('$path must stay inside the repository');
    }
  }

  static String _stableVersion(Object? value, String path) {
    final source = _nonEmptyString(value, path);
    try {
      final version = Version.parse(source);
      if (version.isPreRelease || version.build.isNotEmpty) {
        _fail('$path must be a stable major.minor.patch version');
      }
      return version.toString();
    } on FormatException {
      _fail('$path must be a stable major.minor.patch version');
    }
  }

  static String _gitSha(Object? value, String path) {
    final sha = _nonEmptyString(value, path);
    if (!RegExp(r'^(?:[a-f0-9]{40}|[a-f0-9]{64})$').hasMatch(sha)) {
      _fail('$path must be a complete Git SHA');
    }
    return sha;
  }

  static DateTime _dateTime(Object? value, String path) {
    final source = _nonEmptyString(value, path);
    try {
      return DateTime.parse(source).toUtc();
    } on FormatException {
      _fail('$path must be an ISO-8601 date-time');
    }
  }

  static String _boundedNote(Object? value, String path, Platform platform) {
    final note = _nonEmptyString(value, path);
    final maximumCharacters = switch (platform) {
      Platform.android => 500,
      Platform.ios => 4000,
    };
    if (note.length > maximumCharacters) {
      _fail('$path must be at most $maximumCharacters characters');
    }
    return note;
  }

  static Never _fail(String message) {
    throw SmfError(message, 'INVALID_CONFIG');
  }
}
