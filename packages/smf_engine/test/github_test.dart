import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

import 'support/recording_process.dart';

final class FakeGitHubApi implements GitHubApi {
  final List<GitHubPullRequest> pulls = <GitHubPullRequest>[];
  final List<({int number, String title})> updates = <({int number, String title})>[];
  final List<({String head, String base, String title})> creates = <({String head, String base, String title})>[];
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
    await GitClient(root: origin.path).run(const <String>['init', '--bare']);
    await Directory(p.join(root.path, 'ios')).create();
    await File(
      p.join(root.path, 'pubspec.yaml'),
    ).writeAsString('name: example\nversion: 1.0.0+1\n');
    await File(p.join(root.path, 'app.txt')).writeAsString('baseline\n');
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
    final paths = SmfPaths.resolve(root.path);
    await File(paths.beforeCreatePrHook).parent.create(recursive: true);
    await File(
      paths.beforeCreatePrHook,
    ).writeAsString('Future<void> main() async {}\n');
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>[
      'commit',
      '-m',
      'chore: configure releases',
    ]);
    await GitClient(root: root.path).run(<String>['remote', 'add', 'origin', origin.path]);
    await GitClient(root: root.path).run(const <String>['push', '-u', 'origin', 'main']);
    await File(p.join(root.path, 'app.txt')).writeAsString('feature\n');
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>[
      'commit',
      '-m',
      'feat(ios): add offline mode',
    ]);
    await GitClient(root: root.path).run(const <String>['push', 'origin', 'main']);
    final releasePlanner = ReleasePlanner.forRepository(
      repositoryRoot: root.path,
      appId: 'example',
    );
    final plan = await releasePlanner.create(
      manifest: await SmfState.manifest(root.path),
      platform: Platform.ios,
    );
    expect(plan, isNotNull);
    final api = FakeGitHubApi();
    const context = GitHubContext(
      owner: 'example',
      repo: 'app',
      token: 'unused',
    );
    final config = await SmfState.config(root.path);
    final hookRunner = RecordingProcessRunner(
      handler: (invocation) async {
        await File(
          p.join(root.path, 'generated-release-notes.txt'),
        ).writeAsString('generated');
        await File(
          invocation.options.environment['SMF_HOOK_RESULT_PATH']!,
        ).writeAsString('{"schemaVersion":1}');
        return const RunResult(stdout: '', stderr: '', exitCode: 0);
      },
    );

    final result = await ReleasePullRequest.createOrUpdate(
      workingDirectory: root.path,
      config: config,
      plans: <ReleasePlan>[plan!],
      context: context,
      githubApi: api,
      hookProcessRunner: hookRunner,
    );

    expect(result.branch, 'smf/example/release');
    expect(result.pullRequestNumber, 42);
    expect(api.creates.single.head, 'smf/example/release');
    expect(api.creates.single.base, 'main');
    expect(api.creates.single.title, 'chore(example): release iOS 1.1.0');
    expect(
      await GitClient(root: origin.path).run(const <String>[
        'show',
        'smf/example/release:smf/manifest.json',
      ]),
      contains('"pendingRelease": true'),
    );
    expect(
      await GitClient(root: origin.path).run(const <String>[
        'show',
        'smf/example/release:smf/changelog.json',
      ]),
      contains('"1.1.0"'),
    );
    expect(
      await GitClient(root: origin.path).run(const <String>[
        'show',
        'smf/example/release:smf/store-release-notes.json',
      ], allowFailure: true),
      isEmpty,
    );
    expect(
      await GitClient(root: origin.path).run(const <String>[
        'show',
        'smf/example/release:generated-release-notes.txt',
      ]),
      'generated',
    );
    expect(await GitClient(root: root.path).currentBranch(), 'main');

    await File(p.join(root.path, 'app.txt')).writeAsString('feature and fix\n');
    await GitClient(root: root.path).run(const <String>['add', '.']);
    await GitClient(root: root.path).run(const <String>[
      'commit',
      '-m',
      'fix(ios): correct offline state',
    ]);
    await GitClient(root: root.path).run(const <String>['push', 'origin', 'main']);
    final refreshedPlan = await releasePlanner.create(
      manifest: await SmfState.manifest(root.path),
      platform: Platform.ios,
    );
    await GitClient(root: root.path).run(const <String>['config', '--unset-all', 'user.name']);
    await GitClient(root: root.path).run(const <String>['config', '--unset-all', 'user.email']);
    await ReleasePullRequest.createOrUpdate(
      workingDirectory: root.path,
      config: config,
      plans: <ReleasePlan>[refreshedPlan!],
      context: context,
      githubApi: api,
      hookProcessRunner: hookRunner,
    );
    expect(api.updates.single.number, 42);
    expect(
      api.updates.single.title,
      'chore(example): release iOS 1.1.0',
    );
    expect(
      await GitClient(root: root.path).run(const <String>['config', 'user.name']),
      'smf[bot]',
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
      await GitClient(root: origin.path).run(const <String>['init', '--bare']);
      await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
      await GitClient(root: root.path).run(const <String>['config', 'user.name', 'Test']);
      await GitClient(root: root.path).run(const <String>[
        'config',
        'user.email',
        'test@example.com',
      ]);
      final sourcePath = p.join(root.path, 'app.txt');
      await File(sourcePath).writeAsString('baseline\n');
      await Directory(p.join(root.path, 'smf')).create();
      await File(
        p.join(root.path, 'smf', 'config.yaml'),
      ).writeAsString(
        'schema_version: 1\napp_id: example\nplatforms:\n  ios: {}\n',
      );
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>['commit', '-m', 'chore: bootstrap']);
      await GitClient(root: root.path).run(<String>['remote', 'add', 'origin', origin.path]);
      await GitClient(root: root.path).run(const <String>['push', '-u', 'origin', 'main']);

      await GitClient(root: root.path).run(
        const <String>['checkout', '-b', 'smf/example/release'],
      );
      await File(sourcePath).writeAsString('release branch\n');
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>['commit', '-m', 'chore: release']);
      await GitClient(root: root.path).run(
        const <String>['push', '-u', 'origin', 'smf/example/release'],
      );

      await GitClient(root: root.path).run(const <String>['checkout', 'main']);
      await File(sourcePath).writeAsString('target branch\n');
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await GitClient(root: root.path).run(const <String>['commit', '-m', 'fix: conflict']);
      await GitClient(root: root.path).run(const <String>['push', 'origin', 'main']);

      const config = SmfConfig(appId: 'example', ios: IosConfig());
      const plan = ReleasePlan(
        platform: Platform.ios,
        currentVersion: '1.0.0',
        nextVersion: '1.0.1',
        versionBump: VersionBump.patch,
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
        ReleasePullRequest.createOrUpdate(
          workingDirectory: root.path,
          config: config,
          plans: const <ReleasePlan>[plan],
          context: context,
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
      expect(await GitClient(root: root.path).currentBranch(), 'main');
      expect(await GitClient(root: root.path).isClean(), isTrue);
    },
  );
}
