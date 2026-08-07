import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

final class _ReleasePlanFixture {
  const _ReleasePlanFixture._();

  static Future<(Directory, String)> repository() async {
    final directory = await Directory.systemTemp.createTemp('smf-plan-');
    addTearDown(() => directory.delete(recursive: true));
    final gitClient = GitClient(root: directory.path);
    await gitClient.run(const <String>['init', '-b', 'main']);
    await gitClient.run(const <String>['config', 'user.name', 'Test']);
    await gitClient.run(const <String>[
      'config',
      'user.email',
      'test@example.com',
    ]);
    await File(p.join(directory.path, 'app.txt')).writeAsString('baseline\n');
    await gitClient.run(const <String>['add', '.']);
    await gitClient.run(
      const <String>['commit', '-m', 'chore: bootstrap'],
    );
    final remote = await Directory.systemTemp.createTemp('smf-plan-remote-');
    addTearDown(() => remote.delete(recursive: true));
    await GitClient(root: remote.path).run(const <String>['init', '--bare']);
    await gitClient.run(<String>['remote', 'add', 'origin', remote.path]);
    await gitClient.run(const <String>['push', '-u', 'origin', 'main']);
    return (
      directory,
      await gitClient.run(const <String>['rev-parse', 'HEAD']),
    );
  }

  static Future<void> commit(
    String root,
    String message,
    String content,
  ) async {
    await File(p.join(root, 'app.txt')).writeAsString(content);
    final gitClient = GitClient(root: root);
    await gitClient.run(const <String>['add', '.']);
    await gitClient.run(<String>['commit', '-m', message]);
  }

  static Future<void> commitPath(
    String root,
    String path,
    String message,
    String content,
  ) async {
    final file = File(p.join(root, path));
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
    final gitClient = GitClient(root: root);
    await gitClient.run(const <String>['add', '.']);
    await gitClient.run(<String>['commit', '-m', message]);
  }

  static ManifestDto manifest(
    String version,
    String endCommitHash, {
    bool isReleasePending = false,
  }) {
    return ManifestDto(
      schemaVersion: 1,
      platforms: ManifestPlatformsDto(
        ios: PlatformManifestDto(
          version: version,
          endCommitHash: endCommitHash,
          isReleasePending: isReleasePending,
        ),
        android: PlatformManifestDto(
          version: '0.0.0',
          endCommitHash: endCommitHash,
          isReleasePending: false,
        ),
      ),
    );
  }

  static ReleasePlanner planner(
    String repositoryRoot, {
    String appId = 'example',
    List<String> releaseTriggerPaths = const <String>[],
  }) {
    return ReleasePlanner.forRepository(
      repositoryRoot: repositoryRoot,
      appId: appId,
      releaseTriggerPaths: releaseTriggerPaths,
    );
  }
}

void main() {
  test(
    'when release trigger paths are exposed, they should reject mutation',
    () {
      final planner = ReleasePlanner(
        gitClient: const GitClient(root: '/tmp/repository'),
        appId: 'example',
        releaseTriggerPaths: <String>['apps/example'],
      );

      expect(
        planner.releaseTriggerPaths.clear,
        throwsUnsupportedError,
      );
    },
  );

  group('release planning', () {
    test('bumps iOS independently and excludes Android-only changes', () async {
      final (directory, endCommitHash) = await _ReleasePlanFixture.repository();
      await _ReleasePlanFixture.commit(directory.path, 'feat(ios): add widgets', 'ios\n');
      await _ReleasePlanFixture.commit(
        directory.path,
        'fix(android): repair back button',
        'android\n',
      );

      final plan =
          await _ReleasePlanFixture.planner(
            directory.path,
          ).create(
            manifest: _ReleasePlanFixture.manifest(
              '1.2.3',
              endCommitHash,
            ),
            platform: ReleasePlatform.ios,
            gitHubToken: 'token',
          );

      expect(plan?.nextVersion, '1.3.0');
      expect(
        plan?.changes.map((change) => change.description),
        <String>['add widgets'],
      );
    });

    test('plans iOS and Android independently from the same history', () async {
      final (directory, endCommitHash) = await _ReleasePlanFixture.repository();
      await _ReleasePlanFixture.commit(directory.path, 'feat: shared capability', 'shared\n');
      await _ReleasePlanFixture.commit(directory.path, 'fix(android): Android repair', 'android\n');
      final state = ManifestDto(
        schemaVersion: 1,
        platforms: ManifestPlatformsDto(
          ios: PlatformManifestDto(
            version: '2.0.0',
            endCommitHash: endCommitHash,
            isReleasePending: false,
          ),
          android: PlatformManifestDto(
            version: '1.4.2',
            endCommitHash: endCommitHash,
            isReleasePending: false,
          ),
        ),
      );

      final planner = _ReleasePlanFixture.planner(directory.path);
      final ios = await planner.create(
        manifest: state,
        platform: ReleasePlatform.ios,
        gitHubToken: 'token',
      );
      final android = await planner.create(
        manifest: state,
        platform: ReleasePlatform.android,
        gitHubToken: 'token',
      );

      expect(ios?.nextVersion, '2.1.0');
      expect(ios?.changes.map((change) => change.description), <String>[
        'shared capability',
      ]);
      expect(android?.nextVersion, '1.5.0');
      expect(android?.changes.map((change) => change.description), <String>[
        'shared capability',
        'Android repair',
      ]);
    });

    test('uses the platform tag as the next release baseline', () async {
      final (directory, endCommitHash) = await _ReleasePlanFixture.repository();
      await _ReleasePlanFixture.commit(directory.path, 'feat: already released', 'released\n');
      await GitClient(root: directory.path).run(<String>[
        'tag',
        ReleaseReference.tag('example', ReleasePlatform.ios, '2.0.0'),
      ]);
      await GitClient(root: directory.path).run(const <String>[
        'push',
        'origin',
        'example/ios-v2.0.0',
      ]);
      await GitClient(root: directory.path).run(const <String>[
        'tag',
        '--delete',
        'example/ios-v2.0.0',
      ]);
      await _ReleasePlanFixture.commit(directory.path, 'fix: new patch', 'patch\n');
      final state = _ReleasePlanFixture.manifest(
        '2.0.0',
        endCommitHash,
        isReleasePending: true,
      );

      final planner = _ReleasePlanFixture.planner(directory.path);
      final plan = await planner.create(
        manifest: state,
        platform: ReleasePlatform.ios,
        gitHubToken: 'token',
      );

      expect(plan?.nextVersion, '2.0.1');
      expect(plan?.changes, hasLength(1));
      expect(
        await planner.isPromotionNeeded(
          manifest: state,
          platform: ReleasePlatform.ios,
          gitHubToken: 'token',
        ),
        isFalse,
      );
    });

    test('recognizes a merged pending release without a tag', () async {
      final (directory, endCommitHash) = await _ReleasePlanFixture.repository();
      expect(
        await _ReleasePlanFixture.planner(
          directory.path,
        ).isPromotionNeeded(
          manifest: _ReleasePlanFixture.manifest(
            '1.0.0',
            endCommitHash,
            isReleasePending: true,
          ),
          platform: ReleasePlatform.ios,
          gitHubToken: 'token',
        ),
        isTrue,
      );
    });

    test('returns no plan for non-releasable commits', () async {
      final (directory, endCommitHash) = await _ReleasePlanFixture.repository();
      await _ReleasePlanFixture.commit(directory.path, 'chore: update tooling', 'tooling\n');
      expect(
        await _ReleasePlanFixture.planner(
          directory.path,
        ).create(
          manifest: _ReleasePlanFixture.manifest(
            '1.0.0',
            endCommitHash,
          ),
          platform: ReleasePlatform.ios,
          gitHubToken: 'token',
        ),
        isNull,
      );
    });

    test('does not allow a commit footer to override the version', () async {
      final (directory, endCommitHash) = await _ReleasePlanFixture.repository();
      await _ReleasePlanFixture.commit(
        directory.path,
        'feat(android): prepare migration\n\nRelease-As-android: 4.0.0',
        'migration\n',
      );
      final plan =
          await _ReleasePlanFixture.planner(
            directory.path,
          ).create(
            manifest:
                _ReleasePlanFixture.manifest(
                  '1.2.3',
                  endCommitHash,
                ).copyWith(
                  platforms: ManifestPlatformsDto(
                    ios: PlatformManifestDto(
                      version: '1.2.3',
                      endCommitHash: endCommitHash,
                      isReleasePending: false,
                    ),
                    android: PlatformManifestDto(
                      version: '1.2.3',
                      endCommitHash: endCommitHash,
                      isReleasePending: false,
                    ),
                  ),
                ),
            platform: ReleasePlatform.android,
            gitHubToken: 'token',
          );
      expect(plan?.nextVersion, '1.3.0');
    });

    test('isolates app commits and includes configured shared paths', () async {
      final (directory, endCommitHash) = await _ReleasePlanFixture.repository();
      await _ReleasePlanFixture.commitPath(
        directory.path,
        'apps/customer/lib/main.dart',
        'feat: improve customer search',
        'customer\n',
      );
      await _ReleasePlanFixture.commitPath(
        directory.path,
        'apps/driver/lib/main.dart',
        'feat: improve driver routing',
        'driver\n',
      );
      await _ReleasePlanFixture.commitPath(
        directory.path,
        'packages/shared_models/lib/model.dart',
        'fix: repair shared model',
        'shared\n',
      );

      final customerPlanner = _ReleasePlanFixture.planner(
        directory.path,
        appId: 'customer',
        releaseTriggerPaths: const <String>['apps/customer'],
      );
      final customer = await customerPlanner.create(
        manifest: _ReleasePlanFixture.manifest(
          '1.0.0',
          endCommitHash,
        ),
        platform: ReleasePlatform.ios,
        gitHubToken: 'token',
      );
      final customerWithShared =
          await _ReleasePlanFixture.planner(
            directory.path,
            appId: 'customer',
            releaseTriggerPaths: const <String>[
              'apps/customer',
              'packages/shared_models/**',
            ],
          ).create(
            manifest: _ReleasePlanFixture.manifest(
              '1.0.0',
              endCommitHash,
            ),
            platform: ReleasePlatform.ios,
            gitHubToken: 'token',
          );

      expect(
        customer?.changes.map((change) => change.description),
        <String>['improve customer search'],
      );
      expect(
        customerWithShared?.changes.map((change) => change.description),
        <String>['improve customer search', 'repair shared model'],
      );
    });
  });
}
