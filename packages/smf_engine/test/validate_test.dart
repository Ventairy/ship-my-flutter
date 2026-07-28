import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

Future<Directory> _createValidRepository() async {
  final root = await Directory.systemTemp.createTemp('smf-validate-hook-');
  await Directory(p.join(root.path, 'ios')).create();
  await File(
    p.join(root.path, 'pubspec.yaml'),
  ).writeAsString('name: example\nversion: 1.0.0+1\n');
  await File(
    p.join(root.path, 'pubspec.lock'),
  ).writeAsString('# fixture\n');
  final git = GitClient(root: root.path);
  await git.run(const <String>['init', '-b', 'main']);
  await git.run(const <String>['config', 'user.name', 'Test']);
  await git.run(const <String>[
    'config',
    'user.email',
    'test@example.com',
  ]);
  await git.run(const <String>['add', '.']);
  await git.run(const <String>['commit', '-m', 'chore: bootstrap']);
  await RepositoryInitializer.initialize(
    InitOptions(
      appRoot: root.path,
      iosBundleId: 'dev.example.app',
    ),
  );
  await git.run(const <String>['add', '.']);
  await git.run(const <String>[
    'commit',
    '-m',
    'chore: configure releases',
  ]);
  return root;
}

void main() {
  test('repository validation requires the release lockfile in Git', () async {
    final root = await Directory.systemTemp.createTemp('smf-validate-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 1.0.0+1\n');
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
    await GitClient(root: root.path).run(const <String>['config', 'user.name', 'Test']);
    await GitClient(root: root.path).run(const <String>[
      'config',
      'user.email',
      'test@example.com',
    ]);
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>['commit', '-m', 'chore: bootstrap']);
    await RepositoryInitializer.initialize(
      InitOptions(appRoot: root.path, iosBundleId: 'dev.example.app'),
    );
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>[
      'commit',
      '-m',
      'chore: configure releases',
    ]);

    await expectLater(
      RepositoryValidator.validate(root.path),
      throwsA(
        isA<SmfError>().having(
          (error) => error.message,
          'message',
          contains('No committed pubspec.lock'),
        ),
      ),
    );
    await File(p.join(root.path, 'pubspec.lock')).writeAsString('# fixture\n');
    await expectLater(
      RepositoryValidator.validate(root.path),
      throwsA(
        isA<SmfError>().having(
          (error) => error.message,
          'message',
          contains('pubspec.lock must be committed'),
        ),
      ),
    );
    await GitClient(root: root.path).run(const <String>['add', 'pubspec.lock']);
    await GitClient(root: root.path).run(const <String>[
      'commit',
      '-m',
      'chore: lock dependencies',
    ]);
    await RepositoryValidator.validate(root.path);
  });

  test(
    'when a recognized hook is untracked, it should reject validation',
    () async {
      final root = await _createValidRepository();
      addTearDown(() => root.delete(recursive: true));
      final hook = File(
        p.join(root.path, 'smf', 'hooks', 'before_create_pr.dart'),
      );
      await hook.parent.create(recursive: true);
      await hook.writeAsString('Future<void> main() async {}\n');
      await expectLater(
        RepositoryValidator.validate(root.path),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'UNTRACKED_HOOK',
          ),
        ),
      );
    },
  );

  test(
    'when a recognized hook is a symbolic link, it should reject validation',
    () async {
      final root = await _createValidRepository();
      addTearDown(() => root.delete(recursive: true));
      final hookPath = p.join(
        root.path,
        'smf',
        'hooks',
        'before_create_pr.dart',
      );
      await Directory(p.dirname(hookPath)).create(recursive: true);
      await Link(hookPath).create(p.join(root.path, 'pubspec.yaml'));

      await expectLater(
        RepositoryValidator.validate(root.path),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'INVALID_HOOK_FILE',
          ),
        ),
      );
    },
  );

  test('repository validation rejects duplicate app IDs', () async {
    final root = await Directory.systemTemp.createTemp('smf-validate-');
    addTearDown(() => root.delete(recursive: true));
    await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
    await GitClient(root: root.path).run(const <String>['config', 'user.name', 'Test']);
    await GitClient(root: root.path).run(const <String>[
      'config',
      'user.email',
      'test@example.com',
    ]);
    await File(p.join(root.path, 'README.md')).writeAsString('fixture\n');
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>['commit', '-m', 'chore: bootstrap']);
    for (final app in <String>['customer', 'driver']) {
      final appRoot = p.join(root.path, 'apps', app);
      await Directory(p.join(appRoot, 'smf')).create(recursive: true);
      await File(
        p.join(appRoot, 'pubspec.yaml'),
      ).writeAsString('name: $app\n');
      await File(
        p.join(appRoot, 'smf', 'config.yaml'),
      ).writeAsString('''
schema_version: 1
app_id: mobile
platforms:
  android:
    enabled: true
''');
    }

    await expectLater(
      RepositoryValidator.validate(p.join(root.path, 'apps', 'customer', 'smf')),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'APP_ID_CONFLICT',
        ),
      ),
    );
  });
}
