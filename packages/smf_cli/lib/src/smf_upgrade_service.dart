part of 'upgrade.dart';

/// Checks for and installs published SMF CLI updates.
final class SmfUpgradeService {
  const SmfUpgradeService({
    required LatestSmfVersionLoader latestVersionLoader,
    required SmfInstaller installer,
  }) : _latestVersionLoader = latestVersionLoader,
       _installer = installer;

  factory SmfUpgradeService.system() => SmfUpgradeService(
    latestVersionLoader: _loadLatestPublishedVersion,
    installer: (executable, arguments) => dart_io.Process.run(
      executable,
      arguments,
      runInShell: dart_io.Platform.isWindows,
    ),
  );

  final LatestSmfVersionLoader _latestVersionLoader;
  final SmfInstaller _installer;

  /// Returns the newer published version, or `null` when this CLI is current.
  Future<String?> newerVersion() async {
    final latest = await _latestVersionLoader();
    if (latest == null) return null;
    final installedVersion = Version.parse(smfCliVersion);
    final latestVersion = Version.parse(latest);
    return latestVersion > installedVersion ? latestVersion.toString() : null;
  }

  /// Installs the latest published CLI and describes the completed operation.
  Future<Map<String, Object?>> upgrade() async {
    final latest = await _latestVersionLoader();
    if (latest == null) {
      _throwUpgradeCheckFailed();
    }
    final installedVersion = Version.parse(smfCliVersion);
    final Version latestVersion;
    try {
      latestVersion = Version.parse(latest);
    } on FormatException {
      _throwUpgradeCheckFailed();
    }
    if (latestVersion <= installedVersion) {
      return <String, Object?>{
        'isUpgraded': false,
        'version': smfCliVersion,
        'message': 'SMF is already up to date.',
      };
    }

    final dart_io.ProcessResult result;
    try {
      result = await _installer('dart', <String>[
        'install',
        'smf_cli',
        latestVersion.toString(),
        '--overwrite',
      ]);
    } on dart_io.ProcessException {
      _throwUpgradeFailed();
    }
    if (result.exitCode != 0) {
      _throwUpgradeFailed();
    }
    return <String, Object?>{
      'isUpgraded': true,
      'previousVersion': smfCliVersion,
      'version': latestVersion.toString(),
    };
  }

  static Never _throwUpgradeCheckFailed() => throw const SmfError(
    'Could not find the latest smf_cli version on pub.dev. Check the '
    'network connection and try again.',
    SmfErrorCode.upgradeCheckFailed,
  );

  static Never _throwUpgradeFailed() => throw const SmfError(
    'Dart could not install the latest SMF CLI. Run '
    '`dart install smf_cli --overwrite` to see the installer diagnostics.',
    SmfErrorCode.upgradeFailed,
  );

  static Future<String?> _loadLatestPublishedVersion() async {
    final client = dart_io.HttpClient()
      ..connectionTimeout = const Duration(seconds: 2)
      ..userAgent = 'smf/$smfCliVersion';
    try {
      final request = await client.getUrl(
        Uri.https('pub.dev', '/api/packages/smf_cli'),
      );
      request.headers.set(
        dart_io.HttpHeaders.acceptHeader,
        'application/json',
      );
      final response = await request.close().timeout(
        const Duration(seconds: 3),
      );
      if (response.statusCode != dart_io.HttpStatus.ok) {
        await response.drain<void>();
        return null;
      }
      final body = await utf8.decoder.bind(response).join().timeout(const Duration(seconds: 3));
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, Object?>) return null;
      final latest = decoded['latest'];
      if (latest is! Map<String, Object?>) return null;
      final version = latest['version'];
      return version is String && version.trim().isNotEmpty ? version.trim() : null;
    } on Object {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
