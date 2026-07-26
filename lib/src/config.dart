import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'error.dart';
import 'model.dart';
import 'paths.dart';
import 'serialization.dart';

const Set<String> _managedFlutterBuildArguments = <String>{
  '--build-name',
  '--build-number',
  '--export-options-plist',
  '--release',
  '--debug',
  '--profile',
  '--flavor',
  '--pub',
  '--no-pub',
};

const Set<String> _rootConfigFields = <String>{
  'schemaVersion',
  'targetBranch',
  'releaseBranchPrefix',
  'hooks',
  'platforms',
};
const Set<String> _hookFields = <String>{'beforeReleasePr'};
const Set<String> _platformFields = <String>{'ios'};
const Set<String> _iosFields = <String>{
  'enabled',
  'projectPath',
  'bundleId',
  'scheme',
  'buildArgs',
  'testflight',
  'appStore',
};
const Set<String> _testflightFields = <String>{'groups', 'waitTimeoutMinutes'};
const Set<String> _appStoreFields = <String>{
  'mode',
  'releaseType',
  'earliestReleaseDate',
};

Future<ShipConfig> loadConfig([String? root]) async {
  final paths = resolveShipPaths(root);
  try {
    return validateConfig(await readYaml(paths.config), source: paths.config);
  } on FileSystemException catch (error) {
    throw ShipError(
      'Could not read ${paths.config}: ${error.message}',
      'CONFIG_NOT_FOUND',
      cause: error,
    );
  } on YamlException catch (error) {
    throw ShipError(
      '${paths.config} is invalid:\n$error',
      'INVALID_CONFIG',
      cause: error,
    );
  }
}

Future<ShipManifest> loadManifest([String? root]) async {
  final paths = resolveShipPaths(root);
  return validateManifest(
    await _loadJson(paths.manifest),
    source: paths.manifest,
  );
}

Future<ChangelogManifest> loadChangelog([String? root]) async {
  final paths = resolveShipPaths(root);
  return validateChangelog(
    await _loadJson(paths.changelog),
    source: paths.changelog,
  );
}

Future<StoreReleaseNotes> loadStoreReleaseNotes([String? root]) async {
  final paths = resolveShipPaths(root);
  return validateStoreReleaseNotes(
    await _loadJson(paths.storeReleaseNotes),
    source: paths.storeReleaseNotes,
  );
}

Future<Object?> _loadJson(String filePath) async {
  try {
    return await readJson(filePath);
  } on FileSystemException catch (error) {
    throw ShipError(
      'Could not read $filePath: ${error.message}',
      'CONFIG_NOT_FOUND',
      cause: error,
    );
  } on FormatException catch (error) {
    throw ShipError(
      '$filePath is invalid:\n${error.message}',
      'INVALID_CONFIG',
      cause: error,
    );
  }
}

ShipConfig validateConfig(Object? value, {String source = 'configuration'}) {
  try {
    final root = _objectMap(value, source);
    _schemaVersion(root, source);
    _rejectUnknownFields(root, _rootConfigFields, source);
    final hooks = _objectMap(
      root['hooks'] ?? const <String, Object?>{},
      'hooks',
    );
    _rejectUnknownFields(hooks, _hookFields, 'hooks');
    final platforms = _objectMap(root['platforms'], 'platforms');
    _rejectUnknownFields(platforms, _platformFields, 'platforms');
    final ios = _objectMap(platforms['ios'], 'platforms.ios');
    _rejectUnknownFields(ios, _iosFields, 'platforms.ios');

    return ShipConfig(
      targetBranch: _nonEmptyString(
        root['targetBranch'] ?? 'main',
        'targetBranch',
      ),
      releaseBranchPrefix: _nonEmptyString(
        root['releaseBranchPrefix'] ?? 'ship-my-flutter',
        'releaseBranchPrefix',
      ),
      hooks: _parseHooks(hooks),
      ios: _parseIosConfig(ios),
    );
  } on ShipError {
    rethrow;
  } on FormatException catch (error) {
    throw ShipError(
      '$source is invalid:\n${error.message}',
      'INVALID_CONFIG',
      cause: error,
    );
  }
}

HooksConfig _parseHooks(Map<String, Object?> hooks) {
  final beforeReleasePr = _optionalString(
    hooks['beforeReleasePr'],
    'hooks.beforeReleasePr',
  );
  if (beforeReleasePr != null) {
    _relativePath(beforeReleasePr, 'hooks.beforeReleasePr');
  }
  return HooksConfig(beforeReleasePr: beforeReleasePr);
}

IosConfig _parseIosConfig(Map<String, Object?> ios) {
  final projectPath = _nonEmptyString(
    ios['projectPath'] ?? '.',
    'platforms.ios.projectPath',
  );
  _relativePath(projectPath, 'platforms.ios.projectPath');
  final buildArgs = _stringList(
    ios['buildArgs'] ?? const <Object?>[],
    'platforms.ios.buildArgs',
  );
  _validateBuildArguments(buildArgs);

  final testflight = _objectMap(
    ios['testflight'] ?? const <String, Object?>{},
    'platforms.ios.testflight',
  );
  _rejectUnknownFields(
    testflight,
    _testflightFields,
    'platforms.ios.testflight',
  );
  final appStore = _objectMap(
    ios['appStore'] ?? const <String, Object?>{},
    'platforms.ios.appStore',
  );
  _rejectUnknownFields(appStore, _appStoreFields, 'platforms.ios.appStore');

  return IosConfig(
    enabled: _boolean(ios['enabled'] ?? true, 'platforms.ios.enabled'),
    projectPath: projectPath,
    bundleId: _optionalNonEmptyString(
      ios['bundleId'],
      'platforms.ios.bundleId',
    ),
    scheme: _optionalNonEmptyString(ios['scheme'], 'platforms.ios.scheme'),
    buildArgs: List<String>.unmodifiable(buildArgs),
    testflight: _parseTestflightConfig(testflight),
    appStore: _parseAppStoreConfig(appStore),
  );
}

void _validateBuildArguments(List<String> buildArgs) {
  for (final argument in buildArgs) {
    final managed = _managedFlutterBuildArguments.any(
      (String name) => argument == name || argument.startsWith('$name='),
    );
    if (managed) {
      _fail(
        'platforms.ios.buildArgs: This flag is managed by ship-my-flutter '
        'and cannot be set in buildArgs',
      );
    }
  }
}

TestflightConfig _parseTestflightConfig(Map<String, Object?> testflight) {
  final groups = _stringList(
    testflight['groups'] ?? const <Object?>[],
    'platforms.ios.testflight.groups',
    nonEmpty: true,
  );
  final waitTimeoutMinutes = _integer(
    testflight['waitTimeoutMinutes'] ?? 45,
    'platforms.ios.testflight.waitTimeoutMinutes',
  );
  if (waitTimeoutMinutes < 5 || waitTimeoutMinutes > 180) {
    _fail(
      'platforms.ios.testflight.waitTimeoutMinutes must be between 5 and 180',
    );
  }
  return TestflightConfig(
    groups: List<String>.unmodifiable(groups),
    waitTimeoutMinutes: waitTimeoutMinutes,
  );
}

AppStoreConfig _parseAppStoreConfig(Map<String, Object?> appStore) {
  final releaseMode = switch (_nonEmptyString(
    appStore['mode'] ?? 'upload-only',
    'platforms.ios.appStore.mode',
  )) {
    'submit-for-review' => ReleaseMode.submitForReview,
    'upload-only' => ReleaseMode.uploadOnly,
    final String invalid => _fail(
      'platforms.ios.appStore.mode must be submit-for-review or upload-only, '
      'not "$invalid"',
    ),
  };
  final releaseType = switch (_nonEmptyString(
    appStore['releaseType'] ?? 'manual',
    'platforms.ios.appStore.releaseType',
  )) {
    'manual' => StoreReleaseType.manual,
    'automatic' => StoreReleaseType.automatic,
    'scheduled' => StoreReleaseType.scheduled,
    final String invalid => _fail(
      'platforms.ios.appStore.releaseType must be manual, automatic, or '
      'scheduled, not "$invalid"',
    ),
  };
  final earliestValue = _optionalString(
    appStore['earliestReleaseDate'],
    'platforms.ios.appStore.earliestReleaseDate',
  );
  final earliestReleaseDate = earliestValue == null
      ? null
      : _dateTime(earliestValue, 'platforms.ios.appStore.earliestReleaseDate');
  _validateReleaseDate(releaseType, earliestReleaseDate);
  return AppStoreConfig(
    mode: releaseMode,
    releaseType: releaseType,
    earliestReleaseDate: earliestReleaseDate,
  );
}

void _validateReleaseDate(
  StoreReleaseType releaseType,
  DateTime? earliestReleaseDate,
) {
  if (releaseType == StoreReleaseType.scheduled &&
      earliestReleaseDate == null) {
    _fail(
      'platforms.ios.appStore.earliestReleaseDate is required when '
      'releaseType is scheduled',
    );
  }
  if (releaseType != StoreReleaseType.scheduled &&
      earliestReleaseDate != null) {
    _fail(
      'platforms.ios.appStore.earliestReleaseDate is only valid when '
      'releaseType is scheduled',
    );
  }
}

ShipManifest validateManifest(Object? value, {String source = 'manifest'}) {
  try {
    final root = _objectMap(value, source);
    _schemaVersion(root, source);
    final platforms = _objectMap(root['platforms'], 'platforms');
    final ios = _objectMap(platforms['ios'], 'platforms.ios');
    return ShipManifest(
      ios: PlatformManifest(
        version: _stableVersion(ios['version'], 'platforms.ios.version'),
        baselineSha: _gitSha(ios['baselineSha'], 'platforms.ios.baselineSha'),
        pendingRelease: _boolean(
          ios['pendingRelease'],
          'platforms.ios.pendingRelease',
        ),
      ),
    );
  } on ShipError {
    rethrow;
  } on FormatException catch (error) {
    throw ShipError(
      '$source is invalid:\n${error.message}',
      'INVALID_CONFIG',
      cause: error,
    );
  }
}

ChangelogManifest validateChangelog(
  Object? value, {
  String source = 'changelog',
}) {
  try {
    final root = _objectMap(value, source);
    _schemaVersion(root, source);
    final platforms = _objectMap(root['platforms'], 'platforms');
    final ios = _objectMap(platforms['ios'], 'platforms.ios');
    final releases = _objectMap(ios['releases'], 'platforms.ios.releases');
    final parsed = <String, ChangelogRelease>{};
    for (final entry in releases.entries) {
      final release = _objectMap(
        entry.value,
        'platforms.ios.releases.${entry.key}',
      );
      final version = _stableVersion(
        release['version'],
        'platforms.ios.releases.${entry.key}.version',
      );
      if (version != entry.key) {
        _fail(
          'platforms.ios.releases.${entry.key}.version must match its '
          'release key ${entry.key}',
        );
      }
      final changesValue = release['changes'];
      if (changesValue is! List<Object?> || changesValue.isEmpty) {
        _fail(
          'platforms.ios.releases.${entry.key}.changes must contain at least '
          'one change',
        );
      }
      final changes = <ConventionalChange>[
        for (var index = 0; index < changesValue.length; index++)
          _parseChange(
            changesValue[index],
            'platforms.ios.releases.${entry.key}.changes.$index',
          ),
      ];
      parsed[entry.key] = ChangelogRelease(
        version: version,
        preparedAt: _dateTime(
          release['preparedAt'],
          'platforms.ios.releases.${entry.key}.preparedAt',
        ),
        baseSha: _gitSha(
          release['baseSha'],
          'platforms.ios.releases.${entry.key}.baseSha',
        ),
        headSha: _gitSha(
          release['headSha'],
          'platforms.ios.releases.${entry.key}.headSha',
        ),
        changes: List<ConventionalChange>.unmodifiable(changes),
      );
    }
    return ChangelogManifest(
      iosReleases: Map<String, ChangelogRelease>.unmodifiable(parsed),
    );
  } on ShipError {
    rethrow;
  } on FormatException catch (error) {
    throw ShipError(
      '$source is invalid:\n${error.message}',
      'INVALID_CONFIG',
      cause: error,
    );
  }
}

StoreReleaseNotes validateStoreReleaseNotes(
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
              ),
          },
      };
    }
    return result;
  } on ShipError {
    rethrow;
  } on FormatException catch (error) {
    throw ShipError(
      '$source is invalid:\n${error.message}',
      'INVALID_CONFIG',
      cause: error,
    );
  }
}

ConventionalChange _parseChange(Object? value, String path) {
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
    bump: Bump.maybeParse(change['bump']),
    platforms: List<Platform>.unmodifiable(
      platformsValue.map(
        (Object? item) =>
            Platform.parse(_nonEmptyString(item, '$path.platforms')),
      ),
    ),
    releaseAs: change['releaseAs'] == null
        ? null
        : _stableVersion(change['releaseAs'], '$path.releaseAs'),
  );
}

void _schemaVersion(Map<String, Object?> value, String source) {
  if (value['schemaVersion'] != 1) {
    _fail('$source.schemaVersion must be 1');
  }
}

Map<String, Object?> _objectMap(Object? value, String path) {
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

void _rejectUnknownFields(
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

String _nonEmptyString(Object? value, String path) {
  if (value is! String || value.isEmpty) {
    _fail('$path must be a non-empty string');
  }
  return value;
}

String? _optionalString(Object? value, String path) =>
    value == null ? null : _nonEmptyString(value, path);

String? _optionalNonEmptyString(Object? value, String path) =>
    value == null ? null : _nonEmptyString(value, path);

String? _nullableString(Object? value, String path) {
  if (value == null) return null;
  if (value is! String) _fail('$path must be a string or null');
  return value;
}

bool _boolean(Object? value, String path) {
  if (value is! bool) _fail('$path must be a boolean');
  return value;
}

int _integer(Object? value, String path) {
  if (value is! int) _fail('$path must be an integer');
  return value;
}

List<String> _stringList(Object? value, String path, {bool nonEmpty = false}) {
  if (value is! List<Object?>) _fail('$path must be a list');
  return <String>[
    for (var index = 0; index < value.length; index++)
      nonEmpty
          ? _nonEmptyString(value[index], '$path.$index')
          : _string(value[index], '$path.$index'),
  ];
}

String _string(Object? value, String path) {
  if (value is! String) _fail('$path must be a string');
  return value;
}

void _relativePath(String value, String path) {
  if (p.isAbsolute(value) ||
      p.posix.isAbsolute(value) ||
      p.windows.isAbsolute(value)) {
    _fail('$path must be a relative path');
  }
  if (value.split(RegExp(r'[/\\]')).contains('..')) {
    _fail('$path must stay inside the repository');
  }
}

String _stableVersion(Object? value, String path) {
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

String _gitSha(Object? value, String path) {
  final sha = _nonEmptyString(value, path);
  if (!RegExp(r'^(?:[a-f0-9]{40}|[a-f0-9]{64})$').hasMatch(sha)) {
    _fail('$path must be a complete Git SHA');
  }
  return sha;
}

DateTime _dateTime(Object? value, String path) {
  final source = _nonEmptyString(value, path);
  try {
    return DateTime.parse(source).toUtc();
  } on FormatException {
    _fail('$path must be an ISO-8601 date-time');
  }
}

String _boundedNote(Object? value, String path) {
  final note = _nonEmptyString(value, path);
  if (note.length > 4000) _fail('$path must be at most 4000 characters');
  return note;
}

Never _fail(String message) {
  throw ShipError(message, 'INVALID_CONFIG');
}
