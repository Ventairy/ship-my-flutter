import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_android/src/android/signing.dart';
import 'package:smf_android/src/models/android_signing_credentials.dart';
import 'package:smf_engine/smf_engine.dart' hide Platform;

/// Finds exactly one repository-contained Android App Bundle.
Future<String> findAab(
  String projectRoot, {
  String aabOutputPath = 'build/app/outputs/bundle/release',
}) async {
  final normalizedRoot = p.normalize(p.absolute(projectRoot));
  final configuredPath = p.normalize(
    p.absolute(normalizedRoot, aabOutputPath),
  );
  invariant(
    p.equals(configuredPath, normalizedRoot) ||
        p.isWithin(normalizedRoot, configuredPath),
    'The configured aab_output_path must stay inside the Flutter app.',
    'AAB_PATH_ESCAPE',
  );
  final type = await FileSystemEntity.type(configuredPath);
  invariant(
    type != FileSystemEntityType.notFound,
    'The build command did not produce an AAB at $configuredPath.',
    'AAB_NOT_FOUND',
  );
  final realRoot = await Directory(normalizedRoot).resolveSymbolicLinks();
  final realConfiguredPath = await switch (type) {
    FileSystemEntityType.file => File(configuredPath).resolveSymbolicLinks(),
    FileSystemEntityType.directory => Directory(
      configuredPath,
    ).resolveSymbolicLinks(),
    _ => throw const SmfError(
      'The configured aab_output_path must be a file or directory.',
      'AAB_NOT_FOUND',
    ),
  };
  invariant(
    p.equals(realConfiguredPath, realRoot) ||
        p.isWithin(realRoot, realConfiguredPath),
    'The configured aab_output_path resolves outside the Flutter app.',
    'AAB_PATH_ESCAPE',
  );
  if (type == FileSystemEntityType.file) {
    invariant(
      configuredPath.toLowerCase().endsWith('.aab'),
      'The configured Android artifact file must have an .aab extension.',
      'AAB_NOT_FOUND',
    );
    return configuredPath;
  }

  final candidates = <String>[];
  await for (final entity in Directory(configuredPath).list(recursive: true)) {
    if (entity is! File || !entity.path.toLowerCase().endsWith('.aab')) {
      continue;
    }
    final realFile = await entity.resolveSymbolicLinks();
    invariant(
      p.isWithin(realRoot, realFile),
      'An AAB in aab_output_path resolves outside the Flutter app.',
      'AAB_PATH_ESCAPE',
    );
    candidates.add(entity.path);
  }
  candidates.sort();
  invariant(
    candidates.length == 1,
    'Expected exactly one AAB in $configuredPath, found ${candidates.length}.',
    'AAB_COUNT',
  );
  return candidates.single;
}

/// Selects a project-owned command or the repository-aware Flutter default.
Future<String> resolveAndroidBuildCommand(
  String projectRoot, {
  String? configuredCommand,
}) async {
  if (configuredCommand != null) return configuredCommand;

  var directory = p.normalize(p.absolute(projectRoot));
  while (true) {
    final usesFvm =
        await File(p.join(directory, '.fvmrc')).exists() ||
        await File(p.join(directory, '.fvm', 'fvm_config.json')).exists();
    if (usesFvm) return 'fvm flutter build appbundle --release';

    final gitBoundary =
        await File(p.join(directory, '.git')).exists() ||
        await Directory(p.join(directory, '.git')).exists();
    final parent = p.dirname(directory);
    if (gitBoundary || parent == directory) break;
    directory = parent;
  }
  return 'flutter build appbundle --release';
}

/// Builds and verifies an AAB signed by the configured Google Play upload key.
Future<String> runAndroidBuildCommand({
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
  await runShellCommand(
    managedCommand.toString(),
    options: RunOptions(
      workingDirectory: projectRoot,
      environment: environment,
    ),
    processRunner: processRunner,
  );
  final aabPath = await findAab(
    projectRoot,
    aabOutputPath: aabOutputPath,
  );
  await signAabUploadKey(
    aabPath,
    signing.keystorePath,
    credentials,
    processRunner: processRunner,
  );
  await verifyAabUploadKey(
    aabPath,
    signing.keystorePath,
    credentials,
    processRunner: processRunner,
  );
  return aabPath;
}

/// Replaces any local/template signature with the configured upload key.
Future<void> signAabUploadKey(
  String aabPath,
  String keystorePath,
  AndroidSigningCredentials credentials, {
  ProcessRunner processRunner = const SystemProcessRunner(),
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
    options: const RunOptions(allowFailure: true),
  );
  invariant(
    stripped.exitCode == 0 || stripped.exitCode == 12,
    'Could not remove the existing AAB signature before applying the upload '
        'key.',
    'AAB_SIGNING_FAILED',
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

/// Verifies the AAB signature and exact upload certificate.
Future<void> verifyAabUploadKey(
  String aabPath,
  String keystorePath,
  AndroidSigningCredentials credentials, {
  ProcessRunner processRunner = const SystemProcessRunner(),
}) async {
  final verification = await processRunner.run('jarsigner', <String>[
    '-verify',
    '-certs',
    aabPath,
  ]);
  invariant(
    '${verification.stdout}\n${verification.stderr}'.contains('jar verified.'),
    'jarsigner did not verify the Android App Bundle signature.',
    'AAB_SIGNING_INVALID',
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
  invariant(
    expectedSha256 == actualSha256,
    'The AAB was not signed by the configured Google Play upload key '
        '(expected $expectedSha256, found $actualSha256).',
    'AAB_SIGNING_MISMATCH',
  );
}

String _certificateSha256(String output) {
  final match = RegExp(
    r'SHA256:\s*([0-9A-Fa-f:]{64,})',
  ).firstMatch(output);
  final value = match?.group(1)?.replaceAll(':', '').toLowerCase();
  if (value == null || !RegExp(r'^[a-f0-9]{64}$').hasMatch(value)) {
    throw const SmfError(
      'Could not read a SHA-256 certificate fingerprint from keytool.',
      'KEYTOOL_OUTPUT',
    );
  }
  return value;
}
