import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

Future<void> _createSmfConfig(String appRoot) async {
  final directory = Directory(p.join(appRoot, 'smf'));
  await directory.create(recursive: true);
  await File(
    p.join(directory.path, 'config.yaml'),
  ).writeAsString(
    'schema_version: 3\napp_id: example\nplatforms:\n  ios: {}\n',
  );
}

void main() {
  test('discovers one nested app and derives all three roots', () async {
    final repository = await Directory.systemTemp.createTemp('smf-paths-');
    addTearDown(() => repository.delete(recursive: true));
    await GitClient(root: repository.path).run(const <String>['init', '-b', 'main']);
    final app = p.join(repository.path, 'packages', 'mobile');
    await _createSmfConfig(app);

    final paths = SmfPaths.resolve(repository.path);

    expect(paths.repositoryRoot, repository.path);
    expect(paths.appRoot, app);
    expect(paths.directory, p.join(app, 'smf'));
    expect(
      paths.beforeCreatePrHook,
      p.join(app, 'smf', 'hooks', 'before_create_pr.dart'),
    );
  });

  test('requires an explicit path when more than one app is found', () async {
    final repository = await Directory.systemTemp.createTemp('smf-paths-');
    addTearDown(() => repository.delete(recursive: true));
    await GitClient(root: repository.path).run(const <String>['init', '-b', 'main']);
    await _createSmfConfig(p.join(repository.path, 'apps', 'consumer'));
    await _createSmfConfig(p.join(repository.path, 'apps', 'worker'));

    expect(
      () => SmfPaths.resolve(repository.path),
      throwsA(
        isA<SmfError>()
            .having(
              (error) => error.code,
              'code',
              'MULTIPLE_SMF_DIRECTORIES',
            )
            .having(
              (error) => error.message,
              'message',
              allOf(contains('apps/consumer/smf'), contains('apps/worker/smf')),
            ),
      ),
    );

    final selected = SmfPaths.resolve(
      repository.path,
      smfPath: p.join('apps', 'worker', 'smf'),
    );
    expect(selected.appRoot, p.join(repository.path, 'apps', 'worker'));
  });

  test('prunes caches, hidden directories, and symbolic links', () async {
    final repository = await Directory.systemTemp.createTemp('smf-paths-');
    final external = await Directory.systemTemp.createTemp('smf-external-');
    addTearDown(() async {
      await repository.delete(recursive: true);
      await external.delete(recursive: true);
    });
    await GitClient(root: repository.path).run(const <String>['init', '-b', 'main']);
    await _createSmfConfig(p.join(repository.path, 'app'));
    await _createSmfConfig(p.join(repository.path, 'build', 'ignored'));
    await _createSmfConfig(p.join(repository.path, '.hidden', 'ignored'));
    await _createSmfConfig(p.join(external.path, 'linked'));
    await Link(
      p.join(repository.path, 'linked-app'),
    ).create(p.join(external.path, 'linked'));

    expect(
      SmfPaths.resolve(repository.path).directory,
      p.join(repository.path, 'app', 'smf'),
    );
  });

  test('rejects explicit paths outside the working directory', () async {
    final repository = await Directory.systemTemp.createTemp('smf-paths-');
    final external = await Directory.systemTemp.createTemp('smf-external-');
    addTearDown(() async {
      await repository.delete(recursive: true);
      await external.delete(recursive: true);
    });
    await GitClient(root: repository.path).run(const <String>['init', '-b', 'main']);
    await _createSmfConfig(external.path);

    expect(
      () => SmfPaths.resolve(
        repository.path,
        smfPath: p.join(external.path, 'smf'),
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'INVALID_SMF_PATH',
        ),
      ),
    );
  });
}
