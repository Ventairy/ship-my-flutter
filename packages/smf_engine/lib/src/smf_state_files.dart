part of 'config.dart';

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
  static const Set<String> _manifestRootFields = <String>{
    'schemaVersion',
    'platforms',
  };
  static const Set<String> _platformManifestFields = <String>{
    'version',
    'endCommitHash',
    'isReleasePending',
    'baselineSha',
    'pendingRelease',
  };
  static const Set<String> _changelogRootFields = <String>{
    'schemaVersion',
    'platforms',
  };
  static const Set<String> _changelogPlatformFields = <String>{'releases'};
  static const Set<String> _changelogReleaseFields = <String>{
    'version',
    'preparedAt',
    'baseCommitHash',
    'endCommitHash',
    'changes',
  };
  static const Set<String> _conventionalChangeFields = <String>{
    'commitHash',
    'type',
    'scope',
    'description',
    'body',
    'isBreaking',
    'versionBumpType',
    'platforms',
  };

  static Future<SmfConfig> loadConfig([String? root]) async {
    final paths = SmfPaths.resolve(root);
    try {
      return validateConfig(
        await YamlFile(paths.config).read(),
        source: paths.config,
      );
    } on FileSystemException catch (error) {
      throw SmfError(
        'Could not read ${paths.config}: ${error.message}',
        SmfErrorCode.configNotFound,
        cause: error,
      );
    } on YamlException catch (error) {
      throw SmfError(
        '${paths.config} is invalid:\n$error',
        SmfErrorCode.invalidConfig,
        cause: error,
      );
    } on FormatException catch (error) {
      throw SmfError(
        '${paths.config} is invalid:\n${error.message}',
        SmfErrorCode.invalidConfig,
        cause: error,
      );
    }
  }

  /// Loads generated release state or derives the initial state without writing.
  ///
  /// Before the first release PR, the version comes from `initial_version` and
  /// the ending commit comes from the commit that introduced `config.yaml`.
  static Future<ManifestDto> loadManifest([String? root]) async {
    final paths = SmfPaths.resolve(root);
    if (!(await File(paths.manifest).exists())) {
      final config = await loadConfig(paths.directory);
      final endCommitHash = await _initialEndCommitHash(paths);
      return ManifestDto(
        schemaVersion: 1,
        platforms: ManifestPlatformsDto(
          ios: PlatformManifestDto(
            version: config.ios.initialVersion,
            endCommitHash: endCommitHash,
            isReleasePending: false,
          ),
          android: PlatformManifestDto(
            version: config.android.initialVersion,
            endCommitHash: endCommitHash,
            isReleasePending: false,
          ),
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
  static Future<ChangelogDto> loadChangelog([String? root]) async {
    final paths = SmfPaths.resolve(root);
    if (!(await File(paths.changelog).exists())) {
      return const ChangelogDto(
        schemaVersion: 1,
        platforms: ChangelogPlatformsDto(
          ios: ChangelogPlatformDto(releases: <ChangelogPlatformReleaseVersionDto>[]),
          android: ChangelogPlatformDto(releases: <ChangelogPlatformReleaseVersionDto>[]),
        ),
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
    if (!(await File(paths.storeReleaseNotes).exists())) {
      return const StoreReleaseNotes.empty();
    }
    return validateStoreReleaseNotes(
      await _loadJson(paths.storeReleaseNotes),
      source: paths.storeReleaseNotes,
    );
  }

  static Future<String> _initialEndCommitHash(SmfPaths paths) async {
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
    if (additions.isEmpty) return gitClient.currentCommitHash();

    final introductionCommitHash = additions.split('\n').first;
    final ancestry = await gitClient.run(<String>[
      'rev-list',
      '--parents',
      '-n',
      '1',
      introductionCommitHash,
    ]);
    final commits = ancestry.split(RegExp(r'\s+'));
    return commits.length > 1 ? commits[1] : introductionCommitHash;
  }

  static Future<Map<String, Object?>> _loadJson(String filePath) async {
    return JsonFile(filePath).read();
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
        ios: platforms.containsKey('ios') ? _parseIosConfig(ios) : const IosConfig(isEnabled: false),
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
        SmfErrorCode.invalidConfig,
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
      isEnabled: _boolean(ios['enabled'] ?? true, 'platforms.ios.enabled'),
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
      isEnabled: _boolean(
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
    const releaseCandidateConfigPath = 'platforms.android.google_play.release_candidate';
    final releaseCandidate = _objectMap(
      googlePlay['release_candidate'] ?? const <String, Object?>{},
      releaseCandidateConfigPath,
    );
    _rejectUnknownFields(
      releaseCandidate,
      _googlePlayReleaseCandidateFields,
      releaseCandidateConfigPath,
    );
    final releaseCandidateTarget = _googlePlayReleaseCandidateTarget(
      releaseCandidate['target'] ?? 'internal-testing',
      '$releaseCandidateConfigPath.target',
    );
    final releaseCandidateTracks = _playTracks(
      releaseCandidate['tracks'],
      '$releaseCandidateConfigPath.tracks',
    );
    _validatePlayTracks(
      releaseCandidateTarget == GooglePlayReleaseCandidateTarget.closedTesting,
      releaseCandidateTracks,
      releaseCandidateConfigPath,
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
        target: releaseCandidateTarget,
        tracks: releaseCandidateTracks,
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
      mustBeNonEmpty: true,
    );
    for (final track in tracks) {
      if (!RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(track)) {
        _fail('$path contains a track with unsupported characters');
      }
    }
    _requireUnique(tracks, path);
    return tracks;
  }

  static void _validatePlayTracks(bool isClosedTesting, List<String> tracks, String path) {
    if (isClosedTesting && tracks.isEmpty) {
      _fail('$path.tracks must contain at least one closed-testing track');
    }
    if (!isClosedTesting && tracks.isNotEmpty) {
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
    var isEscaped = false;
    for (var index = 0; index < command.length; index++) {
      final character = command[index];
      if (character == '\n' || character == '\r') {
        _invalidBuildCommandShape(path);
      }
      if (isEscaped) {
        isEscaped = false;
        continue;
      }
      if (quote == "'") {
        if (character == "'") quote = null;
        continue;
      }
      if (character == r'\') {
        isEscaped = true;
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
    if (quote != null || isEscaped) {
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
    const releaseCandidateConfigPath = 'platforms.ios.app_store.release_candidate';
    final releaseCandidate = _objectMap(
      appStore['release_candidate'] ?? const <String, Object?>{},
      releaseCandidateConfigPath,
    );
    _rejectUnknownFields(releaseCandidate, _appleReleaseCandidateFields, releaseCandidateConfigPath);
    final target = _appleReleaseCandidateTarget(
      releaseCandidate['target'] ?? 'internal-testing',
      '$releaseCandidateConfigPath.target',
    );
    final groups = _groups(releaseCandidate['groups'], '$releaseCandidateConfigPath.groups');
    final waitTimeoutMinutes = _integer(
      releaseCandidate['wait_timeout_minutes'] ?? 45,
      '$releaseCandidateConfigPath.wait_timeout_minutes',
    );
    if (waitTimeoutMinutes < 5 || waitTimeoutMinutes > 180) {
      _fail(
        '$releaseCandidateConfigPath.wait_timeout_minutes must be between 5 and 180',
      );
    }
    if (target == AppleReleaseCandidateTarget.externalTesting && groups.isEmpty) {
      _fail('$releaseCandidateConfigPath.groups must contain at least one external group');
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
      mustBeNonEmpty: true,
    );
    _requireUnique(groups, path);
    return groups;
  }

  static void _requireUnique(List<String> values, String path) {
    if (values.toSet().length != values.length) {
      _fail('$path must not contain duplicate values');
    }
  }

  static ManifestDto validateManifest(Object? value, {String source = 'manifest'}) {
    try {
      final root = _objectMap(value, source);
      _rejectUnknownFields(root, _manifestRootFields, source);
      _schemaVersion(root, source);
      final platforms = _objectMap(root['platforms'], 'platforms');
      _rejectUnknownFields(platforms, _platformFields, 'platforms');
      final ios = _objectMap(platforms['ios'], 'platforms.ios');
      final android = _objectMap(platforms['android'], 'platforms.android');
      return ManifestDto(
        schemaVersion: 1,
        platforms: ManifestPlatformsDto(
          ios: _parsePlatformManifest(ios, 'platforms.ios'),
          android: _parsePlatformManifest(android, 'platforms.android'),
        ),
      );
    } on SmfError {
      rethrow;
    } on FormatException catch (error) {
      throw SmfError(
        '$source is invalid:\n${error.message}',
        SmfErrorCode.invalidConfig,
        cause: error,
      );
    }
  }

  static PlatformManifestDto _parsePlatformManifest(
    Map<String, Object?> value,
    String path,
  ) {
    _rejectUnknownFields(value, _platformManifestFields, path);
    final usesCurrentNames = value.containsKey('endCommitHash') || value.containsKey('isReleasePending');
    final usesLegacyNames = value.containsKey('baselineSha') || value.containsKey('pendingRelease');
    if (usesCurrentNames && usesLegacyNames) {
      _fail('$path must not mix current and pre-v1 manifest field names');
    }
    final endCommitHash = _manifestField(
      value,
      current: 'endCommitHash',
      legacy: 'baselineSha',
      path: path,
    );
    final isReleasePending = _manifestField(
      value,
      current: 'isReleasePending',
      legacy: 'pendingRelease',
      path: path,
    );
    return PlatformManifestDto(
      version: _stableVersion(value['version'], '$path.version'),
      endCommitHash: _gitCommitHash(
        endCommitHash.value,
        '$path.${endCommitHash.field}',
      ),
      isReleasePending: _boolean(
        isReleasePending.value,
        '$path.${isReleasePending.field}',
      ),
    );
  }

  static ({Object? value, String field}) _manifestField(
    Map<String, Object?> value, {
    required String current,
    required String legacy,
    required String path,
  }) {
    final hasCurrent = value.containsKey(current);
    final hasLegacy = value.containsKey(legacy);
    if (hasCurrent && hasLegacy) {
      _fail('$path must not mix current and pre-v1 manifest field names');
    }
    return (
      value: hasCurrent ? value[current] : value[legacy],
      field: hasCurrent ? current : legacy,
    );
  }

  static ChangelogDto validateChangelog(
    Object? value, {
    String source = 'changelog',
  }) {
    try {
      final root = _objectMap(value, source);
      _rejectUnknownFields(root, _changelogRootFields, source);
      _schemaVersion(root, source);
      final platforms = _objectMap(root['platforms'], 'platforms');
      _rejectUnknownFields(platforms, _platformFields, 'platforms');
      final ios = _parsePlatformReleases(platforms, ReleasePlatform.ios);
      final android = _parsePlatformReleases(platforms, ReleasePlatform.android);
      return ChangelogDto(
        schemaVersion: 1,
        platforms: ChangelogPlatformsDto(
          ios: ChangelogPlatformDto(releases: ios),
          android: ChangelogPlatformDto(releases: android),
        ),
      );
    } on SmfError {
      rethrow;
    } on FormatException catch (error) {
      throw SmfError(
        '$source is invalid:\n${error.message}',
        SmfErrorCode.invalidConfig,
        cause: error,
      );
    }
  }

  static List<ChangelogPlatformReleaseVersionDto> _parsePlatformReleases(
    Map<String, Object?> platforms,
    ReleasePlatform platform,
  ) {
    final prefix = 'platforms.${platform.value}';
    final value = _objectMap(platforms[platform.value], prefix);
    _rejectUnknownFields(value, _changelogPlatformFields, prefix);
    final releases = value['releases'];
    if (releases is! List<Object?>) {
      _fail('$prefix.releases must be a list');
    }
    final parsed = <ChangelogPlatformReleaseVersionDto>[];
    final versions = <String>{};
    for (var releaseIndex = 0; releaseIndex < releases.length; releaseIndex++) {
      final release = _objectMap(
        releases[releaseIndex],
        '$prefix.releases.$releaseIndex',
      );
      _rejectUnknownFields(
        release,
        _changelogReleaseFields,
        '$prefix.releases.$releaseIndex',
      );
      final version = _stableVersion(
        release['version'],
        '$prefix.releases.$releaseIndex.version',
      );
      if (!versions.add(version)) {
        _fail(
          '$prefix.releases contains duplicate version $version',
        );
      }
      final changesValue = release['changes'];
      if (changesValue is! List<Object?> || changesValue.isEmpty) {
        _fail(
          '$prefix.releases.$releaseIndex.changes must contain at least one '
          'change',
        );
      }
      final changes = <ConventionalChangeDto>[
        for (var changeIndex = 0; changeIndex < changesValue.length; changeIndex++)
          _parseChange(
            changesValue[changeIndex],
            '$prefix.releases.$releaseIndex.changes.$changeIndex',
          ),
      ];
      parsed.add(
        ChangelogPlatformReleaseVersionDto(
          version: version,
          preparedAt: _dateTime(
            release['preparedAt'],
            '$prefix.releases.$releaseIndex.preparedAt',
          ),
          baseCommitHash: _gitCommitHash(
            release['baseCommitHash'],
            '$prefix.releases.$releaseIndex.baseCommitHash',
          ),
          endCommitHash: _gitCommitHash(
            release['endCommitHash'],
            '$prefix.releases.$releaseIndex.endCommitHash',
          ),
          changes: changes,
        ),
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
      final result = <ReleasePlatform, Map<String, Map<String, String>>>{};
      for (final entry in root.entries) {
        final platform = ReleasePlatform.parse(entry.key);
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
        SmfErrorCode.invalidConfig,
        cause: error,
      );
    }
  }

  static ConventionalChangeDto _parseChange(Object? value, String path) {
    final change = _objectMap(value, path);
    _rejectUnknownFields(change, _conventionalChangeFields, path);
    final platformsValue = change['platforms'];
    if (platformsValue is! List<Object?>) {
      _fail('$path.platforms must be a list');
    }
    return ConventionalChangeDto(
      commitHash: _gitCommitHash(
        change['commitHash'],
        '$path.commitHash',
      ),
      type: _nonEmptyString(change['type'], '$path.type'),
      scope: _nullableString(change['scope'], '$path.scope'),
      description: _nonEmptyString(change['description'], '$path.description'),
      body: _nullableString(change['body'], '$path.body'),
      isBreaking: _boolean(change['isBreaking'], '$path.isBreaking'),
      versionBumpType: VersionBumpType.maybeParse(change['versionBumpType']),
      platforms: platformsValue
          .map(
            (item) => ReleasePlatform.parse(_nonEmptyString(item, '$path.platforms')),
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
    if (value['schema_version'] != SmfConfig.currentSchemaVersion) {
      _fail(
        '$source.schema_version must be '
        '${SmfConfig.currentSchemaVersion}',
      );
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

  static List<String> _stringList(
    Object? value,
    String path, {
    bool mustBeNonEmpty = false,
  }) {
    if (value is! List<Object?>) _fail('$path must be a list');
    return <String>[
      for (var index = 0; index < value.length; index++)
        mustBeNonEmpty ? _nonEmptyString(value[index], '$path.$index') : _string(value[index], '$path.$index'),
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

  static String _gitCommitHash(Object? value, String path) {
    final commitHash = _nonEmptyString(value, path);
    if (!RegExp(r'^(?:[a-f0-9]{40}|[a-f0-9]{64})$').hasMatch(commitHash)) {
      _fail('$path must be a complete Git commit hash');
    }
    return commitHash;
  }

  static DateTime _dateTime(Object? value, String path) {
    final source = _nonEmptyString(value, path);
    try {
      return DateTime.parse(source).toUtc();
    } on FormatException {
      _fail('$path must be an ISO-8601 date-time');
    }
  }

  static String _boundedNote(Object? value, String path, ReleasePlatform platform) {
    final note = _nonEmptyString(value, path);
    final maximumCharacters = switch (platform) {
      ReleasePlatform.android => SmfHookProtocol.androidStoreReleaseNotesCharacterLimit,
      ReleasePlatform.ios => SmfHookProtocol.iosStoreReleaseNotesCharacterLimit,
    };
    if (note.length > maximumCharacters) {
      _fail('$path must be at most $maximumCharacters characters');
    }
    return note;
  }

  static Never _fail(String message) {
    throw SmfError(message, SmfErrorCode.invalidConfig);
  }
}
