import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/ios/models/apple_credentials.dart';

/// Builds, validates, and uploads Apple application artifacts.
final class AppleBuild {
  const AppleBuild._();

  static Future<void> _rejectSymbolicLinks(
    String root,
    String target, {
    required String description,
    required SmfErrorCode code,
  }) async {
    final normalizedRoot = p.normalize(p.absolute(root));
    var current = p.normalize(p.absolute(target));
    SmfError.check(
      p.equals(current, normalizedRoot) || p.isWithin(normalizedRoot, current),
      '$description must stay inside $normalizedRoot.',
      code,
    );
    while (true) {
      SmfError.check(
        await FileSystemEntity.type(
              current,
              followLinks: false,
            ) !=
            FileSystemEntityType.link,
        '$description must not contain symbolic links: $current.',
        code,
      );
      if (p.equals(current, normalizedRoot)) return;
      current = p.dirname(current);
    }
  }

  /// Resolves one IPA from a project-relative file or directory.
  ///
  /// Both lexical paths and resolved symlinks must remain under [projectRoot].
  static Future<String> findArtifact(
    String projectRoot, {
    String ipaOutputPath = 'build/ios/ipa',
  }) async {
    final repositoryProjectRoot = p.normalize(p.absolute(projectRoot));
    final configuredPath = p.normalize(
      p.absolute(repositoryProjectRoot, ipaOutputPath),
    );
    SmfError.check(
      p.equals(configuredPath, repositoryProjectRoot) || p.isWithin(repositoryProjectRoot, configuredPath),
      'The configured ipa_output_path must stay inside the Flutter app.',
      SmfErrorCode.ipaPathEscape,
    );

    final entityType = await FileSystemEntity.type(configuredPath);
    SmfError.check(
      entityType != FileSystemEntityType.notFound,
      'The build command did not produce an IPA at $configuredPath.',
      SmfErrorCode.ipaNotFound,
    );
    final realProjectRoot = await Directory(
      repositoryProjectRoot,
    ).resolveSymbolicLinks();
    final realConfiguredPath = await switch (entityType) {
      FileSystemEntityType.file => File(configuredPath).resolveSymbolicLinks(),
      FileSystemEntityType.directory => Directory(
        configuredPath,
      ).resolveSymbolicLinks(),
      _ => throw const SmfError(
        'The configured ipa_output_path must be a file or directory.',
        SmfErrorCode.ipaNotFound,
      ),
    };
    SmfError.check(
      p.equals(realConfiguredPath, realProjectRoot) || p.isWithin(realProjectRoot, realConfiguredPath),
      'The configured ipa_output_path resolves outside the Flutter app.',
      SmfErrorCode.ipaPathEscape,
    );

    if (entityType == FileSystemEntityType.file) {
      SmfError.check(
        configuredPath.toLowerCase().endsWith('.ipa'),
        'The configured artifact file must have an .ipa extension.',
        SmfErrorCode.ipaNotFound,
      );
      return configuredPath;
    }

    List<FileSystemEntity> entries;
    try {
      entries = await Directory(configuredPath).list().toList();
    } on FileSystemException catch (error) {
      throw SmfError(
        'The build command did not produce an IPA in $configuredPath.',
        SmfErrorCode.ipaNotFound,
        cause: error,
      );
    }
    final ipas = <String>[];
    for (final entry in entries) {
      if (entry is! File || !entry.path.toLowerCase().endsWith('.ipa')) {
        continue;
      }
      final realFile = await entry.resolveSymbolicLinks();
      SmfError.check(
        p.isWithin(realProjectRoot, realFile),
        'An IPA in ipa_output_path resolves outside the Flutter app.',
        SmfErrorCode.ipaPathEscape,
      );
      ipas.add(entry.path);
    }
    ipas.sort();
    SmfError.check(
      ipas.length == 1,
      'Expected exactly one IPA in $configuredPath, found ${ipas.length}.',
      SmfErrorCode.ipaCount,
    );
    return ipas.single;
  }

  /// Selects the configured build command or repository-aware default.
  ///
  /// When [configuredCommand] is omitted, a project using a current or legacy
  /// FVM configuration runs `fvm flutter`; other projects run `flutter`
  /// directly. FVM configuration is discovered from [projectRoot] up to the
  /// nearest Git repository boundary.
  static Future<String> resolveCommand(
    String projectRoot, {
    String? configuredCommand,
  }) async {
    if (configuredCommand != null) return configuredCommand;
    final executable = await FlutterToolchain.resolveExecutable(projectRoot);
    return '$executable build ipa --release';
  }

  /// Runs the project-owned command with managed Apple build arguments.
  ///
  /// The consumer must install the command's Flutter/FVM toolchain. This
  /// appends immutable version, build number, export-options, and optional
  /// flavor arguments, then validates [ipaOutputPath].
  static Future<String> run({
    required String projectRoot,
    required String command,
    required String ipaOutputPath,
    required String version,
    required String buildNumber,
    required String exportOptionsPath,
    String? flavor,
    ProcessRunner processRunner = const SystemProcessRunner(),
  }) async {
    final resolvedArtifactPath = p.normalize(
      p.absolute(projectRoot, ipaOutputPath),
    );
    final managedCommand = StringBuffer(command)
      ..write(
        ' \\\n'
        '  --build-name "\$SMF_PLATFORM_VERSION" \\\n'
        '  --build-number "\$SMF_BUILD_NUMBER" \\\n'
        r'  --export-options-plist "$SMF_EXPORT_OPTIONS_PATH"',
      );
    if (flavor != null) {
      managedCommand.write(' \\\n  --flavor "\$SMF_FLAVOR"');
    }
    await SystemProcessRunner.shell(
      managedCommand.toString(),
      options: RunOptions(
        workingDirectory: projectRoot,
        environment: <String, String>{
          'SMF_PLATFORM': 'ios',
          'SMF_PLATFORM_VERSION': version,
          'SMF_BUILD_NUMBER': buildNumber,
          'SMF_EXPORT_OPTIONS_PATH': exportOptionsPath,
          'SMF_IPA_OUTPUT_PATH': resolvedArtifactPath,
          'SMF_FLAVOR': ?flavor,
        },
      ),
      processRunner: processRunner,
    );
    return findArtifact(projectRoot, ipaOutputPath: ipaOutputPath);
  }

  /// Uploads an IPA with App Store Connect API credentials.
  static Future<void> upload({
    required String ipaPath,
    required AppleCredentials credentials,
    ProcessRunner processRunner = const SystemProcessRunner(),
    String? homeDirectory,
  }) async {
    SmfError.check(
      RegExp(r'^[A-Za-z0-9]+$').hasMatch(credentials.keyId),
      'The App Store Connect key ID must contain only letters and digits.',
      SmfErrorCode.invalidCredential,
    );
    final home = p.normalize(
      p.absolute(
        homeDirectory ?? Platform.environment['HOME'] ?? Directory.current.path,
      ),
    );
    final privateKeysDirectory = p.join(
      home,
      '.appstoreconnect',
      'private_keys',
    );
    final keyPath = p.join(
      privateKeysDirectory,
      'AuthKey_${credentials.keyId}.p8',
    );
    await _rejectSymbolicLinks(
      home,
      keyPath,
      description: 'The App Store Connect private-key path',
      code: SmfErrorCode.privateKeyCollision,
    );
    final didPrivateKeysDirectoryExist = await Directory(
      privateKeysDirectory,
    ).exists();
    final didKeyExist = await File(keyPath).exists();
    if (didKeyExist) {
      final existing = (await File(keyPath).readAsString()).trim();
      SmfError.check(
        existing == credentials.privateKey.trim(),
        '$keyPath already exists with different contents.',
        SmfErrorCode.privateKeyCollision,
      );
    } else {
      await Directory(privateKeysDirectory).create(recursive: true);
      await _rejectSymbolicLinks(
        home,
        keyPath,
        description: 'The App Store Connect private-key path',
        code: SmfErrorCode.privateKeyCollision,
      );
      if (!didPrivateKeysDirectoryExist) {
        await processRunner.run('/bin/chmod', <String>[
          '700',
          privateKeysDirectory,
        ]);
      }
      await File(keyPath).writeAsString(credentials.privateKey);
    }
    await processRunner.run('/bin/chmod', <String>['600', keyPath]);

    try {
      await processRunner.run('xcrun', <String>[
        'altool',
        '--upload-app',
        '--type',
        'ios',
        '-f',
        ipaPath,
        '--apiKey',
        credentials.keyId,
        '--apiIssuer',
        credentials.issuerId,
      ]);
    } finally {
      if (!didKeyExist) {
        try {
          await File(keyPath).delete();
        } on FileSystemException {
          // Best-effort cleanup must not replace the upload result.
        }
      }
    }
  }
}
