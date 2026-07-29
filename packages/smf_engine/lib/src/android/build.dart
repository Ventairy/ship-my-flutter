import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/android/models/android_signing_credentials.dart';
import 'package:smf_engine/src/android/signing.dart';

/// Builds and validates Android App Bundles.
final class AndroidBuild {
  const AndroidBuild._();

  /// Finds exactly one repository-contained Android App Bundle.
  static Future<String> findArtifact(
    String projectRoot, {
    String aabOutputPath = 'build/app/outputs/bundle/release',
  }) async {
    final normalizedRoot = p.normalize(p.absolute(projectRoot));
    final configuredPath = p.normalize(
      p.absolute(normalizedRoot, aabOutputPath),
    );
    SmfError.check(
      p.equals(configuredPath, normalizedRoot) || p.isWithin(normalizedRoot, configuredPath),
      'The configured aab_output_path must stay inside the Flutter app.',
      SmfErrorCode.aabPathEscape,
    );
    final type = await FileSystemEntity.type(configuredPath);
    SmfError.check(
      type != FileSystemEntityType.notFound,
      'The build command did not produce an AAB at $configuredPath.',
      SmfErrorCode.aabNotFound,
    );
    final realRoot = await Directory(normalizedRoot).resolveSymbolicLinks();
    final realConfiguredPath = await switch (type) {
      FileSystemEntityType.file => File(configuredPath).resolveSymbolicLinks(),
      FileSystemEntityType.directory => Directory(
        configuredPath,
      ).resolveSymbolicLinks(),
      _ => throw const SmfError(
        'The configured aab_output_path must be a file or directory.',
        SmfErrorCode.aabNotFound,
      ),
    };
    SmfError.check(
      p.equals(realConfiguredPath, realRoot) || p.isWithin(realRoot, realConfiguredPath),
      'The configured aab_output_path resolves outside the Flutter app.',
      SmfErrorCode.aabPathEscape,
    );
    if (type == FileSystemEntityType.file) {
      SmfError.check(
        configuredPath.toLowerCase().endsWith('.aab'),
        'The configured Android artifact file must have an .aab extension.',
        SmfErrorCode.aabNotFound,
      );
      return configuredPath;
    }

    final artifactPaths = <String>[];
    await for (final entity in Directory(configuredPath).list(recursive: true)) {
      if (entity is! File || !entity.path.toLowerCase().endsWith('.aab')) {
        continue;
      }
      final realFile = await entity.resolveSymbolicLinks();
      SmfError.check(
        p.isWithin(realRoot, realFile),
        'An AAB in aab_output_path resolves outside the Flutter app.',
        SmfErrorCode.aabPathEscape,
      );
      artifactPaths.add(entity.path);
    }
    artifactPaths.sort();
    SmfError.check(
      artifactPaths.length == 1,
      'Expected exactly one AAB in $configuredPath, found ${artifactPaths.length}.',
      SmfErrorCode.aabCount,
    );
    return artifactPaths.single;
  }

  /// Selects a project-owned command or the repository-aware Flutter default.
  static Future<String> resolveCommand(
    String projectRoot, {
    String? configuredCommand,
  }) async {
    if (configuredCommand != null) return configuredCommand;
    final executable = await FlutterToolchain.resolveExecutable(projectRoot);
    return '$executable build appbundle --release';
  }

  /// Builds and verifies an AAB signed by the configured upload key.
  static Future<String> run({
    required String projectRoot,
    required String command,
    required String aabOutputPath,
    required String version,
    required String buildNumber,
    required AndroidSigningSession signing,
    required AndroidSigningCredentials credentials,
    String? flavor,
    ProcessRunner processRunner = const SystemProcessRunner(),
  }) async {
    final managedCommand = StringBuffer(command)
      ..write(
        r'''
 \
  --build-name "$SMF_PLATFORM_VERSION" \
  --build-number "$SMF_BUILD_NUMBER"'''
            .trimLeft(),
      );
    if (flavor != null) {
      managedCommand.write(
        r'''
 \
  --flavor "$SMF_FLAVOR"'''
            .trimLeft(),
      );
    }
    final environment = <String, String>{
      'SMF_PLATFORM': 'android',
      'SMF_PLATFORM_VERSION': version,
      'SMF_BUILD_NUMBER': buildNumber,
      'SMF_FLAVOR': ?flavor,
    };
    await SystemProcessRunner.shell(
      managedCommand.toString(),
      options: RunOptions(
        workingDirectory: projectRoot,
        environment: environment,
      ),
      processRunner: processRunner,
    );
    final aabPath = await findArtifact(
      projectRoot,
      aabOutputPath: aabOutputPath,
    );
    await _sign(
      aabPath: aabPath,
      keystorePath: signing.keystorePath,
      credentials: credentials,
      processRunner: processRunner,
    );
    await _verify(
      aabPath: aabPath,
      keystorePath: signing.keystorePath,
      credentials: credentials,
      processRunner: processRunner,
    );
    return aabPath;
  }

  static Future<void> _sign({
    required String aabPath,
    required String keystorePath,
    required AndroidSigningCredentials credentials,
    required ProcessRunner processRunner,
  }) async {
    final stripped = await processRunner.run(
      'zip',
      <String>[
        '-d',
        aabPath,
        'META-INF/*.SF',
        'META-INF/*.RSA',
        'META-INF/*.DSA',
        'META-INF/*.EC',
      ],
      options: const RunOptions(isFailureAllowed: true),
    );
    SmfError.check(
      stripped.exitCode == 0 || stripped.exitCode == 12,
      'Could not remove the existing AAB signature before applying the upload '
      'key.',
      SmfErrorCode.aabSigningFailed,
    );
    final environment = <String, String>{
      'SMF_ANDROID_KEYSTORE_PASSWORD': credentials.keystorePassword,
      'SMF_ANDROID_KEY_PASSWORD': credentials.keyPassword,
    };
    await processRunner.run(
      'jarsigner',
      <String>[
        '-keystore',
        keystorePath,
        '-storepass:env',
        'SMF_ANDROID_KEYSTORE_PASSWORD',
        '-keypass:env',
        'SMF_ANDROID_KEY_PASSWORD',
        aabPath,
        credentials.keyAlias,
      ],
      options: RunOptions(environment: environment),
    );
  }

  static Future<void> _verify({
    required String aabPath,
    required String keystorePath,
    required AndroidSigningCredentials credentials,
    required ProcessRunner processRunner,
  }) async {
    final verification = await processRunner.run('jarsigner', <String>[
      '-verify',
      '-certs',
      aabPath,
    ]);
    SmfError.check(
      '${verification.stdout}\n${verification.stderr}'.contains('jar verified.'),
      'jarsigner did not verify the Android App Bundle signature.',
      SmfErrorCode.aabSigningInvalid,
    );
    final environment = <String, String>{
      'SMF_ANDROID_KEYSTORE_PASSWORD': credentials.keystorePassword,
    };
    final expected = await processRunner.run(
      'keytool',
      <String>[
        '-list',
        '-v',
        '-keystore',
        keystorePath,
        '-alias',
        credentials.keyAlias,
        '-storepass:env',
        'SMF_ANDROID_KEYSTORE_PASSWORD',
      ],
      options: RunOptions(environment: environment),
    );
    final actual = await processRunner.run('keytool', <String>[
      '-printcert',
      '-jarfile',
      aabPath,
    ]);
    final expectedSha256 = _certificateSha256(expected.stdout);
    final actualSha256 = _certificateSha256(actual.stdout);
    SmfError.check(
      expectedSha256 == actualSha256,
      'The AAB was not signed by the configured Google Play upload key '
      '(expected $expectedSha256, found $actualSha256).',
      SmfErrorCode.aabSigningMismatch,
    );
  }

  static String _certificateSha256(String output) {
    final match = RegExp(
      r'SHA256:\s*([0-9A-Fa-f:]{64,})',
    ).firstMatch(output);
    final value = match?.group(1)?.replaceAll(':', '').toLowerCase();
    if (value == null || !RegExp(r'^[a-f0-9]{64}$').hasMatch(value)) {
      throw const SmfError(
        'Could not read a SHA-256 certificate fingerprint from keytool.',
        SmfErrorCode.keytoolOutput,
      );
    }
    return value;
  }
}
