import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

import 'support/recording_process.dart';

final class FakeGitHubApi implements GitHubApi {
  final List<GitHubPullRequestDto> pulls = <GitHubPullRequestDto>[];
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
  Future<GitHubPullRequestDto> createPullRequest({
    required String head,
    required String base,
    required String title,
    required String body,
  }) async {
    creates.add((head: head, base: base, title: title));
    const pull = GitHubPullRequestDto(number: 42);
    pulls.add(pull);
    return pull;
  }

  @override
  Future<GitHubReleaseDto> createRelease({
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
  Future<List<GitHubPullRequestDto>> listPullRequests({
    required String state,
    required String head,
    required String base,
    required int perPage,
  }) async => List<GitHubPullRequestDto>.of(pulls);

  @override
  Future<GitHubReleaseDto?> releaseByTag(String tag) {
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
      platform: ReleasePlatform.ios,
      gitHubToken: 'unused',
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
          p.join(
            invocation.options.workingDirectory!,
            'generated-release-notes.txt',
          ),
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
      plans: <ReleasePlanDto>[plan!],
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
      contains('"isReleasePending": true'),
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
      ], isFailureAllowed: true),
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
      platform: ReleasePlatform.ios,
      gitHubToken: 'unused',
    );
    await GitClient(root: root.path).run(const <String>['config', '--unset-all', 'user.name']);
    await GitClient(root: root.path).run(const <String>['config', '--unset-all', 'user.email']);
    await ReleasePullRequest.createOrUpdate(
      workingDirectory: root.path,
      config: config,
      plans: <ReleasePlanDto>[refreshedPlan!],
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
    'when a single-branch checkout updates an existing release branch, it should fetch the remote branch explicitly',
    () async {
      final source = await Directory.systemTemp.createTemp(
        'smf-github-source-',
      );
      final origin = await Directory.systemTemp.createTemp('smf-origin-');
      final checkout = await Directory.systemTemp.createTemp(
        'smf-github-checkout-',
      );
      addTearDown(() async {
        await source.delete(recursive: true);
        await origin.delete(recursive: true);
        await checkout.delete(recursive: true);
      });
      await GitClient(root: origin.path).run(
        const <String>['init', '--bare', '-b', 'main'],
      );
      await Directory(p.join(source.path, 'ios')).create();
      await File(
        p.join(source.path, 'ios', '.gitkeep'),
      ).writeAsString('');
      await File(
        p.join(source.path, 'pubspec.yaml'),
      ).writeAsString('name: example\nversion: 1.0.0+1\n');
      await File(
        p.join(source.path, 'pubspec.lock'),
      ).writeAsString('# fixture\n');
      final sourceGit = GitClient(root: source.path);
      await sourceGit.run(const <String>['init', '-b', 'main']);
      await sourceGit.run(const <String>['config', 'user.name', 'Test']);
      await sourceGit.run(
        const <String>['config', 'user.email', 'test@example.com'],
      );
      await sourceGit.run(const <String>['add', '.']);
      await sourceGit.run(
        const <String>['commit', '-m', 'chore: bootstrap'],
      );
      await RepositoryInitializer.initialize(
        InitOptions(
          appRoot: source.path,
          iosBundleId: 'dev.example.app',
          shouldCreateGitHubActions: false,
        ),
      );
      await sourceGit.run(const <String>['add', '.']);
      await sourceGit.run(
        const <String>['commit', '-m', 'chore: configure releases'],
      );
      await sourceGit.run(<String>[
        'remote',
        'add',
        'origin',
        origin.path,
      ]);
      await sourceGit.run(const <String>['push', '-u', 'origin', 'main']);
      await sourceGit.run(
        const <String>['switch', '-c', 'smf/example/release'],
      );
      await sourceGit.run(
        const <String>['push', '-u', 'origin', 'smf/example/release'],
      );
      await sourceGit.run(const <String>['switch', 'main']);
      await GitClient(root: source.path).run(<String>[
        'clone',
        '--branch',
        'main',
        '--single-branch',
        origin.path,
        checkout.path,
      ]);
      final checkoutGit = GitClient(root: checkout.path);
      final commitHash = await checkoutGit.currentCommitHash();
      final result = await ReleasePullRequest.createOrUpdate(
        workingDirectory: checkout.path,
        config: await SmfState.config(checkout.path),
        plans: <ReleasePlanDto>[
          ReleasePlanDto(
            platform: ReleasePlatform.ios,
            currentVersion: '1.0.0',
            nextVersion: '1.0.1',
            versionBumpType: VersionBumpType.patch,
            baseCommitHash: commitHash,
            endCommitHash: commitHash,
            changes: <ConventionalChangeDto>[
              ConventionalChangeDto(
                commitHash: commitHash,
                type: 'fix',
                scope: 'ios',
                description: 'Fix launch',
                body: null,
                isBreaking: false,
                versionBumpType: VersionBumpType.patch,
                platforms: const <ReleasePlatform>[ReleasePlatform.ios],
              ),
            ],
          ),
        ],
        context: const GitHubContext(
          owner: 'example',
          repo: 'app',
          token: 'unused',
        ),
        githubApi: FakeGitHubApi(),
      );

      expect(
        (
          releaseBranch: result.branch,
          currentBranch: await checkoutGit.currentBranch(),
          remotePrepared: (await GitClient(root: origin.path).run(
            const <String>[
              'show',
              'smf/example/release:smf/manifest.json',
            ],
          )).contains('"isReleasePending": true'),
        ),
        (
          releaseBranch: 'smf/example/release',
          currentBranch: 'main',
          remotePrepared: true,
        ),
      );
    },
  );

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
      const plan = ReleasePlanDto(
        platform: ReleasePlatform.ios,
        currentVersion: '1.0.0',
        nextVersion: '1.0.1',
        versionBumpType: VersionBumpType.patch,
        baseCommitHash: 'base',
        endCommitHash: 'head',
        changes: <ConventionalChangeDto>[],
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
          plans: const <ReleasePlanDto>[plan],
          context: context,
          githubApi: FakeGitHubApi(),
        ),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.commandFailed,
          ),
        ),
      );
      expect(await GitClient(root: root.path).currentBranch(), 'main');
      expect(await GitClient(root: root.path).isClean(), isTrue);
    },
  );
}
