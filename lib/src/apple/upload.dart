import 'dart:io';

import 'package:path/path.dart' as p;

import '../error.dart';
import '../model.dart' hide Platform;
import '../process_runner.dart';
import '../serialization.dart';

Future<String> findIpa(String projectRoot) async {
  final directory = p.join(projectRoot, 'build', 'ios', 'ipa');
  List<FileSystemEntity> entries;
  try {
    entries = await Directory(directory).list().toList();
  } on FileSystemException catch (error) {
    throw ShipError(
      'Flutter did not produce an IPA in $directory.',
      'IPA_NOT_FOUND',
      cause: error,
    );
  }
  final ipas =
      entries
          .whereType<File>()
          .where((File item) => item.path.endsWith('.ipa'))
          .map((File item) => item.path)
          .toList()
        ..sort();
  invariant(
    ipas.length == 1,
    'Expected exactly one IPA in $directory, found ${ipas.length}.',
    'IPA_COUNT',
  );
  return ipas.single;
}

Future<String> buildFlutterIpa({
  required String projectRoot,
  required String version,
  required String buildNumber,
  required String exportOptionsPath,
  String? scheme,
  required List<String> buildArgs,
  ProcessRunner processRunner = const SystemProcessRunner(),
}) async {
  final arguments = <String>[
    'build',
    'ipa',
    '--no-pub',
    '--release',
    '--build-name',
    version,
    '--build-number',
    buildNumber,
    '--export-options-plist',
    exportOptionsPath,
    if (scheme != null) ...<String>['--flavor', scheme],
    ...buildArgs,
  ];
  await processRunner.run(
    'flutter',
    arguments,
    options: RunOptions(workingDirectory: projectRoot),
  );
  return findIpa(projectRoot);
}

Future<void> prepareFlutterDependencies(
  String projectRoot, {
  ProcessRunner processRunner = const SystemProcessRunner(),
}) async {
  await processRunner.run('flutter', const <String>[
    'pub',
    'get',
    '--enforce-lockfile',
  ], options: RunOptions(workingDirectory: projectRoot));
}

Future<void> uploadIpa(
  String ipaPath,
  AppleCredentials credentials, {
  ProcessRunner processRunner = const SystemProcessRunner(),
  String? homeDirectory,
}) async {
  final privateKeysDirectory = p.join(
    homeDirectory ?? Platform.environment['HOME'] ?? Directory.current.path,
    '.appstoreconnect',
    'private_keys',
  );
  final keyPath = p.join(
    privateKeysDirectory,
    'AuthKey_${credentials.keyId}.p8',
  );
  final existed = await fileExists(keyPath);
  if (existed) {
    final existing = (await File(keyPath).readAsString()).trim();
    invariant(
      existing == credentials.privateKey.trim(),
      '$keyPath already exists with different contents.',
      'PRIVATE_KEY_COLLISION',
    );
  } else {
    await Directory(privateKeysDirectory).create(recursive: true);
    await File(keyPath).writeAsString(credentials.privateKey);
    await processRunner.run('/bin/chmod', <String>['600', keyPath]);
  }

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
    if (!existed) {
      try {
        await File(keyPath).delete();
      } on FileSystemException {
        // Best-effort cleanup must not replace the upload result.
      }
    }
  }
}
