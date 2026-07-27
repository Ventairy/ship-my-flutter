import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

import 'support/recording_process.dart';

final class FakeGitHubApi implements GitHubApi {
  final List<GitHubPullRequest> pulls = <GitHubPullRequest>[];
  final List<({int number, String title})> updates =
      <({int number, String title})>[];
  final List<({String head, String base, String title})> creates =
      <({String head, String base, String title})>[];
  bool hasPendingLabel = false;

  @override
  Future<void> addLabels({
    required int issueNumber,
    required List<String> labels,
  }) async {}

  @override
  Future<void> createLabel({
    required String name,
    required String color,
  }) async {
    hasPendingLabel = true;
  }

  @override
  Future<GitHubPullRequest> createPullRequest({
    required String head,
    required String base,
    required String title,
    required String body,
  }) async {
    creates.add((head: head, base: base, title: title));
    const pull = GitHubPullRequest(number: 42);
    pulls.add(pull);
    return pull;
  }

  @override
  Future<GitHubRelease> createRelease({
    required String tag,
    required String name,
    required String body,
    required String targetCommitish,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> labelExists(String name) async => hasPendingLabel;

  @override
  Future<List<GitHubPullRequest>> listPullRequests({
    required String state,
    required String head,
    required String base,
    required int perPage,
  }) async => List<GitHubPullRequest>.of(pulls);

  @override
  Future<GitHubRelease?> releaseByTag(String tag) {
    throw UnimplementedError();
  }

  @override
  Future<void> updatePullRequest({
    required int number,
    required String title,
    required String body,
  }) async {
    updates.add((number: number, title: title));
  }
}

void main() {
  test('creates, pushes, and updates a platform release branch', () async {
    final root = await Directory.systemTemp.createTemp('smf-github-');
    final origin = await Directory.systemTemp.createTemp('smf-origin-');
    addTearDown(() async {
      await root.delete(recursive: true);
      await origin.delete(recursive: true);
    });
    await git(origin.path, const <String>['init', '--bare']);
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 1.0.0+1\n');
    await File(p.join(root.path, 'app.txt')).writeAsString('baseline\n');
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
    final paths = resolveSmfPaths(root.path);
    await File(paths.beforeCreatePrHook).parent.create(recursive: true);
    await File(
      paths.beforeCreatePrHook,
    ).writeAsString('Future<void> main() async {}\n');
    await git(root.path, const <String>['add', '.']);
    await git(root.path, const <String>[
      'commit',
      '-m',
      'chore: configure releases',
    ]);
    await git(root.path, <String>['remote', 'add', 'origin', origin.path]);
    await git(root.path, const <String>['push', '-u', 'origin', 'main']);
    await File(p.join(root.path, 'app.txt')).writeAsString('feature\n');
    await git(root.path, const <String>['add', '.']);
    await git(root.path, const <String>[
      'commit',
      '-m',
      'feat(ios): add offline mode',
    ]);
    await git(root.path, const <String>['push', 'origin', 'main']);
    final plan = await createReleasePlan(
      root.path,
      await loadManifest(root.path),
      Platform.ios,
    );
    expect(plan, isNotNull);
    final api = FakeGitHubApi();
    const context = GitHubContext(
      owner: 'example',
      repo: 'app',
      token: 'unused',
    );
    final config = await loadConfig(root.path);
    final hookRunner = RecordingProcessRunner(
      handler: (invocation) async {
        await File(
          p.join(root.path, 'generated-release-notes.txt'),
        ).writeAsString('generated');
        await File(
          invocation.options.environment['SMF_HOOK_RESULT_PATH']!,
        ).writeAsString('{"schemaVersion":1,"commitChanges":true}');
        return const RunResult(stdout: '', stderr: '', exitCode: 0);
      },
    );

    final result = await createOrUpdateReleasePullRequest(
      root.path,
      config,
      <ReleasePlan>[plan!],
      context,
      githubApi: api,
      hookProcessRunner: hookRunner,
    );

    expect(result.branch, 'smf/release');
    expect(result.pullRequestNumber, 42);
    expect(api.creates.single.head, 'smf/release');
    expect(api.creates.single.base, 'main');
    expect(api.creates.single.title, 'chore(release): iOS 1.1.0');
    expect(
      await git(origin.path, const <String>[
        'show',
        'smf/release:smf/manifest.json',
      ]),
      contains('"pendingRelease": true'),
    );
    expect(
      await git(origin.path, const <String>[
        'show',
        'smf/release:smf/changelog.json',
      ]),
      contains('"1.1.0"'),
    );
    expect(
      await git(origin.path, const <String>[
        'show',
        'smf/release:smf/store-release-notes.json',
      ], allowFailure: true),
      isEmpty,
    );
    expect(
      await git(origin.path, const <String>[
        'show',
        'smf/release:generated-release-notes.txt',
      ]),
      'generated',
    );
    expect(await currentBranch(root.path), 'main');

    await File(p.join(root.path, 'app.txt')).writeAsString('feature and fix\n');
    await git(root.path, const <String>['add', '.']);
    await git(root.path, const <String>[
      'commit',
      '-m',
      'fix(ios): correct offline state',
    ]);
    await git(root.path, const <String>['push', 'origin', 'main']);
    final refreshedPlan = await createReleasePlan(
      root.path,
      await loadManifest(root.path),
      Platform.ios,
    );
    await git(root.path, const <String>['config', '--unset-all', 'user.name']);
    await git(root.path, const <String>['config', '--unset-all', 'user.email']);
    await createOrUpdateReleasePullRequest(
      root.path,
      config,
      <ReleasePlan>[refreshedPlan!],
      context,
      githubApi: api,
      hookProcessRunner: hookRunner,
    );
    expect(api.updates.single.number, 42);
    expect(api.updates.single.title, 'chore(release): iOS 1.1.0');
    expect(
      await git(root.path, const <String>['config', 'user.name']),
      'smf[bot]',
    );

    final noCommitRunner = RecordingProcessRunner(
      handler: (invocation) async {
        await File(
          p.join(root.path, 'uncommitted-hook-output.txt'),
        ).writeAsString('uncommitted');
        await File(
          invocation.options.environment['SMF_HOOK_RESULT_PATH']!,
        ).writeAsString('{"schemaVersion":1,"commitChanges":false}');
        return const RunResult(stdout: '', stderr: '', exitCode: 0);
      },
    );
    await expectLater(
      createOrUpdateReleasePullRequest(
        root.path,
        config,
        <ReleasePlan>[refreshedPlan],
        context,
        githubApi: api,
        hookProcessRunner: noCommitRunner,
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'CREATE_PR_HOOK_DIRTY_WORKTREE',
        ),
      ),
    );
  });

  test(
    'restores the starting branch after a release-branch merge fails',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'smf-github-conflict-',
      );
      final origin = await Directory.systemTemp.createTemp('smf-origin-');
      addTearDown(() async {
        await root.delete(recursive: true);
        await origin.delete(recursive: true);
      });
      await git(origin.path, const <String>['init', '--bare']);
      await git(root.path, const <String>['init', '-b', 'main']);
      await git(root.path, const <String>['config', 'user.name', 'Test']);
      await git(root.path, const <String>[
        'config',
        'user.email',
        'test@example.com',
      ]);
      final sourcePath = p.join(root.path, 'app.txt');
      await File(sourcePath).writeAsString('baseline\n');
      await Directory(p.join(root.path, 'smf')).create();
      await File(
        p.join(root.path, 'smf', 'config.yaml'),
      ).writeAsString('schema_version: 1\nplatforms:\n  ios: {}\n');
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>['commit', '-m', 'chore: bootstrap']);
      await git(root.path, <String>['remote', 'add', 'origin', origin.path]);
      await git(root.path, const <String>['push', '-u', 'origin', 'main']);

      await git(root.path, const <String>['checkout', '-b', 'smf/release']);
      await File(sourcePath).writeAsString('release branch\n');
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>['commit', '-m', 'chore: release']);
      await git(
        root.path,
        const <String>['push', '-u', 'origin', 'smf/release'],
      );

      await git(root.path, const <String>['checkout', 'main']);
      await File(sourcePath).writeAsString('target branch\n');
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>['commit', '-m', 'fix: conflict']);
      await git(root.path, const <String>['push', 'origin', 'main']);

      const config = SmfConfig(ios: IosConfig());
      const plan = ReleasePlan(
        platform: Platform.ios,
        currentVersion: '1.0.0',
        nextVersion: '1.0.1',
        bump: Bump.patch,
        baseSha: 'base',
        headSha: 'head',
        changes: <ConventionalChange>[],
      );
      const context = GitHubContext(
        owner: 'example',
        repo: 'app',
        token: 'unused',
      );

      await expectLater(
        createOrUpdateReleasePullRequest(
          root.path,
          config,
          const <ReleasePlan>[plan],
          context,
          githubApi: FakeGitHubApi(),
        ),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'COMMAND_FAILED',
          ),
        ),
      );
      expect(await currentBranch(root.path), 'main');
      expect(await isClean(root.path), isTrue);
    },
  );
}
