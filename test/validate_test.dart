import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf/smf.dart';
import 'package:test/test.dart';

void main() {
  test('repository validation requires the release lockfile in Git', () async {
    final root = await Directory.systemTemp.createTemp('smf-validate-');
    addTearDown(() => root.delete(recursive: true));
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 1.0.0+1\n');
    await git(root.path, const <String>['init', '-b', 'main']);
    await git(root.path, const <String>['config', 'user.name', 'Test']);
    await git(root.path, const <String>[
      'config',
      'user.email',
      'test@example.com',
    ]);
    await git(root.path, const <String>['add', '.']);
    await git(root.path, const <String>['commit', '-m', 'chore: bootstrap']);
    await initialize(
      InitOptions(appRoot: root.path, bundleId: 'dev.example.app'),
    );
    await git(root.path, const <String>['add', '.']);
    await git(root.path, const <String>[
      'commit',
      '-m',
      'chore: configure releases',
    ]);

    await expectLater(
      validateRepository(root.path),
      throwsA(
        isA<SmfError>().having(
          (SmfError error) => error.message,
          'message',
          contains('No committed pubspec.lock'),
        ),
      ),
    );
    await File(p.join(root.path, 'pubspec.lock')).writeAsString('# fixture\n');
    await expectLater(
      validateRepository(root.path),
      throwsA(
        isA<SmfError>().having(
          (SmfError error) => error.message,
          'message',
          contains('pubspec.lock must be committed'),
        ),
      ),
    );
    await git(root.path, const <String>['add', 'pubspec.lock']);
    await git(root.path, const <String>[
      'commit',
      '-m',
      'chore: lock dependencies',
    ]);
    await validateRepository(root.path);
  });
}
