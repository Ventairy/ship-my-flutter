import 'dart:convert';
import 'dart:io';

import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

String repeated(String value, int count) => List<String>.filled(count, value).join();

ConventionalChangeDto change({
  required String commitHash,
  required String description,
  required VersionBumpType versionBumpType,
}) => ConventionalChangeDto(
  commitHash: commitHash,
  type: 'feat',
  scope: 'ios',
  description: description,
  body: null,
  isBreaking: versionBumpType == VersionBumpType.major,
  versionBumpType: versionBumpType,
  platforms: const <ReleasePlatform>[ReleasePlatform.ios],
);

Future<Directory> stateDirectory({
  required String version,
  required bool isReleasePending,
  required List<ChangelogPlatformReleaseVersionDto> releases,
}) async {
  final root = await Directory.systemTemp.createTemp('smf-manifest-');
  addTearDown(() => root.delete(recursive: true));
  final gitClient = GitClient(root: root.path);
  await gitClient.run(const <String>['init', '-b', 'main']);
  final remote = await Directory.systemTemp.createTemp('smf-manifest-remote-');
  addTearDown(() => remote.delete(recursive: true));
  await GitClient(root: remote.path).run(const <String>['init', '--bare']);
  await gitClient.run(<String>['remote', 'add', 'origin', remote.path]);
  final state = Directory('${root.path}/smf');
  await state.create();
  await File(
    '${state.path}/config.yaml',
  ).writeAsString(
    'schema_version: 1\napp_id: example\nplatforms:\n  ios: {}\n',
  );
  final paths = SmfPaths.resolve(root.path);
  await Directory(paths.releaseCandidates).create();
  final manifest = ManifestDto(
    schemaVersion: 1,
    platforms: ManifestPlatformsDto(
      ios: PlatformManifestDto(
        version: version,
        endCommitHash: repeated('a', 40),
        isReleasePending: isReleasePending,
      ),
      android: PlatformManifestDto(
        version: '0.0.0',
        endCommitHash: repeated('a', 40),
        isReleasePending: false,
      ),
    ),
  );
  final changelog = ChangelogDto(
    schemaVersion: 1,
    platforms: ChangelogPlatformsDto(
      ios: ChangelogPlatformDto(releases: releases),
      android: const ChangelogPlatformDto(
        releases: <ChangelogPlatformReleaseVersionDto>[],
      ),
    ),
  );
  await File(
    paths.manifest,
  ).writeAsString('${_prettyJson(manifest.toJson())}\n');
  await File(
    paths.changelog,
  ).writeAsString('${_prettyJson(changelog.toJson())}\n');
  return root;
}

String _prettyJson(Object? value) {
  return const JsonEncoder.withIndent('  ').convert(value);
}

void main() {
  group('release manifests', () {
    test('replaces an abandoned pending changelog version', () async {
      final oldChange = change(
        commitHash: repeated('b', 40),
        description: 'Old plan',
        versionBumpType: VersionBumpType.minor,
      );
      final root = await stateDirectory(
        version: '1.1.0',
        isReleasePending: true,
        releases: <ChangelogPlatformReleaseVersionDto>[
          ChangelogPlatformReleaseVersionDto(
            version: '1.1.0',
            preparedAt: DateTime.utc(2026, 7, 25),
            baseCommitHash: repeated('a', 40),
            endCommitHash: repeated('b', 40),
            changes: <ConventionalChangeDto>[oldChange],
          ),
        ],
      );
      final receipt = File(
        SmfPaths.resolve(root.path).releaseCandidateReceiptPath(
          platform: ReleasePlatform.ios,
          version: '1.1.0',
        ),
      );
      final intent = File(
        SmfPaths.resolve(root.path).releaseCandidateIntentPath(
          platform: ReleasePlatform.ios,
          version: '1.1.0',
        ),
      );
      await receipt.writeAsString('{}\n');
      await intent.writeAsString('{}\n');
      final nextChange = change(
        commitHash: repeated('c', 40),
        description: 'Breaking plan',
        versionBumpType: VersionBumpType.major,
      );
      final plan = ReleasePlanDto(
        platform: ReleasePlatform.ios,
        currentVersion: '1.0.0',
        nextVersion: '2.0.0',
        versionBumpType: VersionBumpType.major,
        baseCommitHash: repeated('a', 40),
        endCommitHash: repeated('c', 40),
        changes: <ConventionalChangeDto>[nextChange],
      );

      await ReleaseRegistry.apply(
        root: root.path,
        plan: plan,
        gitHubToken: 'token',
        preparedAt: DateTime.utc(2026, 7, 26),
      );

      final changelog = await SmfState.changelog(root.path);
      expect(
        changelog.platforms.ios.releases.map((release) => release.version),
        <String>['2.0.0'],
      );
      final manifest = await SmfState.manifest(root.path);
      expect(manifest.platforms.ios.endCommitHash, plan.endCommitHash);
      expect(await receipt.exists(), isFalse);
      expect(await intent.exists(), isFalse);
    });

    test(
      'preserves a tagged release when preparing the next version',
      () async {
        final releasedChange = change(
          commitHash: repeated('b', 40),
          description: 'Released plan',
          versionBumpType: VersionBumpType.minor,
        );
        final root = await stateDirectory(
          version: '1.1.0',
          isReleasePending: true,
          releases: <ChangelogPlatformReleaseVersionDto>[
            ChangelogPlatformReleaseVersionDto(
              version: '1.1.0',
              preparedAt: DateTime.utc(2026, 7, 25),
              baseCommitHash: repeated('a', 40),
              endCommitHash: repeated('b', 40),
              changes: <ConventionalChangeDto>[releasedChange],
            ),
          ],
        );
        final receipt = File(
          SmfPaths.resolve(root.path).releaseCandidateReceiptPath(
            platform: ReleasePlatform.ios,
            version: '1.1.0',
          ),
        );
        await receipt.writeAsString('{}\n');
        await GitClient(root: root.path).run(const <String>['config', 'user.name', 'Test']);
        await GitClient(root: root.path).run(const <String>[
          'config',
          'user.email',
          'test@example.com',
        ]);
        await GitClient(root: root.path).run(const <String>['add', '.']);
        await GitClient(root: root.path).run(const <String>[
          'commit',
          '-m',
          'chore(ios): release 1.1.0',
        ]);
        await GitClient(root: root.path).run(
          const <String>['tag', 'example/ios-v1.1.0'],
        );
        await GitClient(root: root.path).run(const <String>[
          'push',
          'origin',
          'example/ios-v1.1.0',
        ]);
        await GitClient(root: root.path).run(const <String>[
          'tag',
          '--delete',
          'example/ios-v1.1.0',
        ]);
        final head = await GitClient(root: root.path).run(const <String>['rev-parse', 'HEAD']);
        final plan = ReleasePlanDto(
          platform: ReleasePlatform.ios,
          currentVersion: '1.1.0',
          nextVersion: '1.2.0',
          versionBumpType: VersionBumpType.minor,
          baseCommitHash: head,
          endCommitHash: repeated('c', 40),
          changes: <ConventionalChangeDto>[
            change(
              commitHash: repeated('c', 40),
              description: 'Next plan',
              versionBumpType: VersionBumpType.minor,
            ),
          ],
        );

        await ReleaseRegistry.apply(
          root: root.path,
          plan: plan,
          gitHubToken: 'token',
          preparedAt: DateTime.utc(2026, 7, 26),
        );

        final changelog = await SmfState.changelog(root.path);
        expect(
          changelog.platforms.ios.releases.map((release) => release.version),
          <String>['1.2.0', '1.1.0'],
        );
        expect(await receipt.exists(), isTrue);
      },
    );
  });
}
