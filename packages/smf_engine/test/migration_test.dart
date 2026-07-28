import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

String repeated(String value, int count) => List<String>.filled(count, value).join();

Future<(Directory, SmfPaths)> repository() async {
  final root = await Directory.systemTemp.createTemp('smf-migrate-');
  addTearDown(() => root.delete(recursive: true));
  await Directory(p.join(root.path, 'ios')).create();
  await File(
    p.join(root.path, 'pubspec.yaml'),
  ).writeAsString('name: example\nversion: 1.0.0+1\n');
  await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
  await RepositoryInitializer.initialize(
    InitOptions(appRoot: root.path, iosBundleId: 'dev.example.app'),
  );
  return (root, SmfPaths.resolve(root.path));
}

Map<String, Object?> legacyManifest() => <String, Object?>{
  'schemaVersion': 1,
  'platforms': <String, Object?>{
    'ios': <String, Object?>{
      'version': '1.0.0',
      'baselineSha': repeated('a', 40),
      'pendingRelease': false,
    },
  },
};

Map<String, Object?> legacyChangelog() => <String, Object?>{
  'schemaVersion': 1,
  'platforms': <String, Object?>{
    'ios': <String, Object?>{'releases': <String, Object?>{}},
  },
};

Map<String, Object?> legacyReceipt() => <String, Object?>{
  'schemaVersion': 1,
  'platform': 'ios',
  'version': '1.2.3',
  'buildNumber': '7',
  'buildId': 'build-7',
  'appId': 'app-1',
  'bundleId': 'dev.example.app',
  'sourceSha': repeated('a', 40),
  'sourceFingerprint': repeated('b', 64),
  'ipaSha256': repeated('c', 64),
  'uploadedAt': '2026-07-26T00:00:00.000Z',
  'processingState': 'VALID',
  'testflightGroups': <Object?>['Internal'],
};

Future<void> writeJson(String path, Object? value) async {
  await File(path).parent.create(recursive: true);
  await File(path).writeAsString(jsonEncode(value));
}

void main() {
  test('adds a stable app ID and app-scoped workflow to version 1', () async {
    final (root, paths) = await repository();
    await File(paths.config).writeAsString('''
schema_version: 1
target_branch: main
platforms:
  ios:
    enabled: true
''');
    final scopedWorkflow = File(
      p.join(root.path, '.github', 'workflows', 'smf-example.yml'),
    );
    await scopedWorkflow.delete();
    final legacyWorkflow = File(
      p.join(root.path, '.github', 'workflows', 'smf.yml'),
    );
    await legacyWorkflow.writeAsString('legacy\n');

    final result = await SmfMigration.migrate(
      MigrationOptions(workingDirectory: root.path),
    );

    final config = await File(paths.config).readAsString();
    expect(config, contains('schema_version: 3'));
    expect(config, contains('app_id: "example"'));
    expect(await scopedWorkflow.exists(), isTrue);
    expect(
      await scopedWorkflow.readAsString(),
      contains('environment: smf-example'),
    );
    expect(await legacyWorkflow.exists(), isFalse);
    expect(
      result.changedFiles,
      containsAll(<String>[
        'smf/config.yaml',
        '.github/workflows/smf-example.yml',
        '.github/workflows/smf.yml',
      ]),
    );
  });

  test(
    'migrates delivery modes into release-candidate and ship phases',
    () async {
      final (root, paths) = await repository();
      await Directory(p.join(root.path, 'android')).create();
      await File(paths.config).writeAsString('''
# Preserve this project note.
schema_version: 2
app_id: example
target_branch: main
platforms:
  ios:
    enabled: true
    testflight:
      groups:
        - Internal QA
      wait_timeout_minutes: 60
    app_store:
      mode: review
  android:
    enabled: true
    google_play:
      testing_track: partner-qa
      production_track: beta
      mode: auto
''');

      await SmfMigration.migrate(
        MigrationOptions(workingDirectory: root.path, config: true),
      );

      final source = await File(paths.config).readAsString();
      final config = await SmfState.config(root.path);
      expect(source, contains('# Preserve this project note.'));
      expect(source, isNot(contains('testflight:')));
      expect(config.schemaVersion, 3);
      expect(
        config.ios.appStore.releaseCandidate.target,
        AppleReleaseCandidateTarget.internalTesting,
      );
      expect(
        config.ios.appStore.releaseCandidate.groups,
        <String>['Internal QA'],
      );
      expect(config.ios.appStore.releaseCandidate.waitTimeoutMinutes, 60);
      expect(config.ios.appStore.ship?.target, AppleShipTarget.submitForReview);
      expect(
        config.android.googlePlay.releaseCandidate.target,
        GooglePlayReleaseCandidateTarget.closedTesting,
      );
      expect(
        config.android.googlePlay.releaseCandidate.tracks,
        <String>['partner-qa'],
      );
      expect(
        config.android.googlePlay.ship?.target,
        GooglePlayShipTarget.openTesting,
      );
    },
  );

  test('migrates an empty legacy delivery mode as candidate-only', () async {
    final (root, paths) = await repository();
    await File(paths.config).writeAsString(r'''
# yaml-language-server: $schema=https://raw.githubusercontent.com/Ventairy/smf/main/schemas/config.schema.json
# Keep the release owner note.
schema_version: 1
platforms:
  ios:
    initial_version: 1.0.0
    app_store:
      mode:
''');

    await SmfMigration.migrate(
      MigrationOptions(
        workingDirectory: root.path,
        appId: 'example',
        config: true,
      ),
    );

    final source = await File(paths.config).readAsString();
    expect(
      source,
      contains(
        r'# yaml-language-server: $schema=https://raw.githubusercontent.com/Ventairy/smf/main/packages/smf_engine/schemas/config.schema.json',
      ),
    );
    expect(source, isNot(contains('/main/schemas/config.schema.json')));
    final config = await SmfState.config(root.path);
    expect(source, contains('# Keep the release owner note.'));
    expect(config.schemaVersion, 3);
    expect(
      config.ios.appStore.releaseCandidate.target,
      AppleReleaseCandidateTarget.internalTesting,
    );
    expect(config.ios.appStore.ship, isNull);
  });

  test('migrates every changed target when no selector is passed', () async {
    final (root, paths) = await repository();
    final legacyWorkflowPath = p.join(
      root.path,
      '.github',
      'workflows',
      'smf.yml',
    );
    final workflowPath = p.join(
      root.path,
      '.github',
      'workflows',
      'smf-example.yml',
    );
    await File(legacyWorkflowPath).writeAsString('stale\n');
    await writeJson(paths.manifest, legacyManifest());
    await writeJson(paths.changelog, legacyChangelog());
    await writeJson(
      p.join(paths.candidates, 'ios-1.2.3.json'),
      legacyReceipt(),
    );
    await writeJson(paths.storeReleaseNotes, <String, Object?>{});

    final result = await SmfMigration.migrate(
      MigrationOptions(workingDirectory: root.path),
    );

    expect(result.migrated, isTrue);
    expect(result.targets, MigrationTarget.values);
    expect(result.changedFiles, <String>[
      '.github/workflows/smf.yml',
      'smf/manifest.json',
      'smf/changelog.json',
      'smf/candidates/ios-1.2.3.json',
    ]);
    expect(
      await File(workflowPath).readAsString(),
      contains('Ventairy/smf-action@v1'),
    );
    expect(await File(legacyWorkflowPath).exists(), isFalse);
    final manifest = (await SmfFileSystem.readJson(paths.manifest))! as Map<String, Object?>;
    final manifestPlatforms = manifest['platforms']! as Map<String, Object?>;
    expect(manifestPlatforms, contains('android'));
    final changelog = (await SmfFileSystem.readJson(paths.changelog))! as Map<String, Object?>;
    final changelogPlatforms = changelog['platforms']! as Map<String, Object?>;
    expect(changelogPlatforms, contains('android'));
    final receipt =
        (await SmfFileSystem.readJson(
              p.join(paths.candidates, 'ios-1.2.3.json'),
            ))!
            as Map<String, Object?>;
    expect(receipt['schemaVersion'], 2);
    expect(receipt['artifactId'], 'build-7');
    expect(receipt, isNot(contains('ipaSha256')));

    final second = await SmfMigration.migrate(
      MigrationOptions(workingDirectory: root.path),
    );
    expect(second.migrated, isFalse);
    expect(second.changedFiles, isEmpty);
  });

  test('migrates only explicitly selected targets', () async {
    final (root, paths) = await repository();
    final configSource = '${await File(paths.config).readAsString()}# keep\n';
    await File(paths.config).writeAsString(configSource);
    final legacyWorkflowPath = p.join(
      root.path,
      '.github',
      'workflows',
      'smf.yml',
    );
    await File(legacyWorkflowPath).writeAsString('stale\n');
    final receiptPath = p.join(paths.candidates, 'ios-1.2.3.json');
    await writeJson(receiptPath, legacyReceipt());

    final configResult = await SmfMigration.migrate(
      MigrationOptions(workingDirectory: root.path, config: true),
    );

    expect(configResult.migrated, isFalse);
    expect(configResult.targets, <MigrationTarget>[MigrationTarget.config]);
    expect(await File(paths.config).readAsString(), configSource);
    expect(await File(legacyWorkflowPath).readAsString(), 'stale\n');
    expect(
      ((await SmfFileSystem.readJson(receiptPath))! as Map)['schemaVersion'],
      1,
    );

    final selectedResult = await SmfMigration.migrate(
      MigrationOptions(
        workingDirectory: root.path,
        githubActions: true,
        registry: true,
      ),
    );

    expect(selectedResult.targets, <MigrationTarget>[
      MigrationTarget.githubActions,
      MigrationTarget.registry,
    ]);
    expect(selectedResult.changedFiles, <String>[
      '.github/workflows/smf.yml',
      'smf/candidates/ios-1.2.3.json',
    ]);
    expect(await File(legacyWorkflowPath).exists(), isFalse);
    expect(
      ((await SmfFileSystem.readJson(receiptPath))! as Map)['schemaVersion'],
      2,
    );
  });

  test('validates every target before writing changes', () async {
    final (root, paths) = await repository();
    final workflowPath = p.join(
      root.path,
      '.github',
      'workflows',
      'smf.yml',
    );
    await File(workflowPath).writeAsString('stale\n');
    await File(paths.config).writeAsString('''
schema_version: 0
platforms:
  ios: {}
''');

    await expectLater(
      SmfMigration.migrate(MigrationOptions(workingDirectory: root.path)),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'CONFIG_MIGRATION_UNAVAILABLE',
        ),
      ),
    );
    expect(await File(workflowPath).readAsString(), 'stale\n');
  });
}
