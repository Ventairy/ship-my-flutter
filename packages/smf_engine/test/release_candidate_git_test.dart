import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

final class _GitFixture {
  _GitFixture({
    required this.repository,
    required this.origin,
  });

  final Directory repository;
  final Directory origin;

  GitClient get git => GitClient(root: repository.path);

  Future<String> remoteLog() => git.run(const <String>[
    '--git-dir',
    '../origin.git',
    'log',
    '--format=%s',
    'release',
  ]);
}

Future<_GitFixture> _createFixture() async {
  final root = await Directory.systemTemp.createTemp('smf-release-candidate-git-');
  final repository = Directory(p.join(root.path, 'repository'));
  final origin = Directory(p.join(root.path, 'origin.git'));
  await repository.create();
  await origin.create();

  final git = GitClient(root: repository.path);
  await GitClient(root: origin.path).run(const <String>['init', '--bare']);
  await git.run(const <String>['init', '-b', 'release']);
  await File(p.join(repository.path, 'README.md')).writeAsString('example\n');
  await git.configureBotIdentity();
  await git.run(const <String>['add', '.']);
  await git.run(const <String>['commit', '-m', 'chore: bootstrap']);
  await git.run(<String>['remote', 'add', 'origin', origin.path]);
  await git.run(const <String>['push', '-u', 'origin', 'release']);

  addTearDown(() => root.delete(recursive: true));
  return _GitFixture(repository: repository, origin: origin);
}

void main() {
  test('when committing an intent, it should push the intent commit', () async {
    final fixture = await _createFixture();
    const relativePath = '.smf/intent.json';
    await File(
      p.join(fixture.repository.path, relativePath),
    ).create(recursive: true);

    await ReleaseCandidateGit.commitIntent(
      repositoryRoot: fixture.repository.path,
      intentPath: relativePath,
      platform: ReleasePlatform.ios,
      version: '1.2.3',
      github: null,
    );

    expect(
      await fixture.remoteLog(),
      startsWith('chore(ios): prepare store release candidate 1.2.3'),
    );
  });

  test('when committing a receipt, it should push the receipt commit', () async {
    final fixture = await _createFixture();
    const relativePath = '.smf/receipt.json';
    await File(
      p.join(fixture.repository.path, relativePath),
    ).create(recursive: true);

    await ReleaseCandidateGit.commitReceipt(
      repositoryRoot: fixture.repository.path,
      receiptPath: relativePath,
      platform: ReleasePlatform.android,
      version: '2.0.0',
      github: null,
    );

    expect(
      await fixture.remoteLog(),
      startsWith('chore(android): record store release candidate 2.0.0'),
    );
  });

  test(
    'when finalizing a receipt, it should replace the remote intent',
    () async {
      final fixture = await _createFixture();
      const intentPath = '.smf/intent.json';
      const receiptPath = '.smf/receipt.json';
      final intent = File(p.join(fixture.repository.path, intentPath));
      await intent.create(recursive: true);
      await fixture.git.run(const <String>['add', intentPath]);
      await fixture.git.run(const <String>[
        'commit',
        '-m',
        'chore: record intent',
      ]);
      await fixture.git.run(const <String>['push', 'origin', 'release']);
      await intent.delete();
      await File(
        p.join(fixture.repository.path, receiptPath),
      ).create(recursive: true);

      await ReleaseCandidateGit.finalizeReceipt(
        repositoryRoot: fixture.repository.path,
        intentPath: intentPath,
        receiptPath: receiptPath,
        platform: ReleasePlatform.ios,
        version: '1.2.3',
        github: null,
      );

      final remoteTree = await fixture.git.run(const <String>[
        '--git-dir',
        '../origin.git',
        'ls-tree',
        '-r',
        '--name-only',
        'release',
      ]);
      expect(
        (
          log: await fixture.remoteLog(),
          containsIntent: remoteTree.contains(intentPath),
          containsReceipt: remoteTree.contains(receiptPath),
        ),
        (
          log:
              'chore(ios): record store release candidate 1.2.3\n'
              'chore: record intent\n'
              'chore: bootstrap',
          containsIntent: false,
          containsReceipt: true,
        ),
      );
    },
  );

  test(
    'when a before-build hook changes nothing, it should not add a commit',
    () async {
      final fixture = await _createFixture();
      final startingCommitHash = await fixture.git.currentCommitHash();

      await ReleaseCandidateGit.commitBeforeBuildChanges(
        repositoryRoot: fixture.repository.path,
        platform: ReleasePlatform.ios,
        version: '1.2.3',
        startingCommitHash: startingCommitHash,
        github: null,
      );

      expect(await fixture.git.currentCommitHash(), startingCommitHash);
    },
  );
}
