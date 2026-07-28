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

Map<String, Object?> candidateIntent() => <String, Object?>{
  'schemaVersion': 1,
  'platform': 'ios',
  'version': '1.2.3',
  'buildNumber': '8',
  'applicationId': 'dev.example.app',
  'storeApplicationId': 'app-1',
  'sourceSha': repeated('a', 40),
  'sourceFingerprint': repeated('b', 64),
  'artifactSha256': repeated('c', 64),
  'preparedAt': '2026-07-26T00:00:00.000Z',
};

Future<void> writeJson(String path, Object? value) async {
  await File(path).parent.create(recursive: true);
  await File(path).writeAsString(jsonEncode(value));
}

void main() {
  test(
    'when migration result sources change, it should preserve its completed evidence',
    () {
      final targets = <MigrationTarget>[MigrationTarget.config];
      final changedFiles = <String>['smf/config.yaml'];
      final result = MigrationResult(
        targets: targets,
        changedFiles: changedFiles,
      );

      targets.clear();
      changedFiles.clear();

      expect(
        <String, Object?>{
          'targets': result.targets,
          'changedFiles': result.changedFiles,
        },
        <String, Object?>{
          'targets': <MigrationTarget>[MigrationTarget.config],
          'changedFiles': <String>['smf/config.yaml'],
        },
      );
    },
  );

  test(
    'when migration result collections are exposed, they should reject mutation',
    () {
      final result = MigrationResult(
        targets: <MigrationTarget>[MigrationTarget.config],
        changedFiles: <String>['smf/config.yaml'],
      );

      expect(
        <void Function()>[
          result.targets.clear,
          result.changedFiles.clear,
        ],
        everyElement(throwsUnsupportedError),
      );
    },
  );

  test(
    'when migration reads a non-string YAML key, it should report an invalid configuration',
    () async {
      final (root, paths) = await repository();
      await File(paths.config).writeAsString('''
schema_version: 1
1: invalid
''');

      await expectLater(
        SmfMigration.migrate(
          MigrationOptions(
            workingDirectory: root.path,
            config: true,
          ),
        ),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'CONFIG_MIGRATION_INVALID',
          ),
        ),
      );
    },
  );

  test('default migration preserves a CLI-only repository', () async {
    final root = await Directory.systemTemp.createTemp(
      'smf-migrate-manual-',
    );
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: manual_app\nversion: 1.0.0+1\n');
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
    await RepositoryInitializer.initialize(
      InitOptions(
        appRoot: root.path,
        iosBundleId: 'dev.example.manual',
        githubActions: false,
      ),
    );

    final result = await SmfMigration.migrate(
      MigrationOptions(workingDirectory: root.path),
    );

    expect(
      result.targets,
      <MigrationTarget>[
        MigrationTarget.config,
        MigrationTarget.registry,
      ],
    );
    expect(
      await Directory(p.join(root.path, '.github', 'workflows')).exists(),
      isFalse,
    );
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
    final intentPath = p.join(
      paths.candidates,
      'ios-1.2.3.intent.json',
    );
    await writeJson(intentPath, candidateIntent());
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
    expect(
      CandidateIntent.fromJson(
        await SmfFileSystem.readJson(intentPath),
        source: intentPath,
      ).buildNumber,
      '8',
    );

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
