import 'dart:convert';
import 'dart:io';

import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

String repeated(String value, int count) =>
    List<String>.filled(count, value).join();

ConventionalChange change({
  required String sha,
  required String description,
  required Bump bump,
}) => ConventionalChange(
  sha: sha,
  type: 'feat',
  scope: 'ios',
  description: description,
  body: null,
  breaking: bump == Bump.major,
  bump: bump,
  platforms: const <Platform>[Platform.ios],
);

Future<Directory> stateDirectory({
  required String version,
  required bool pendingRelease,
  required Map<String, ChangelogRelease> releases,
}) async {
  final root = await Directory.systemTemp.createTemp('smf-manifest-');
  addTearDown(() => root.delete(recursive: true));
  await git(root.path, const <String>['init', '-b', 'main']);
  final state = Directory('${root.path}/smf');
  await state.create();
  await File(
    '${state.path}/config.yaml',
  ).writeAsString('schema_version: 1\nplatforms:\n  ios: {}\n');
  final paths = resolveSmfPaths(root.path);
  await Directory(paths.candidates).create();
  final manifest = SmfManifest(
    ios: PlatformManifest(
      version: version,
      baselineSha: repeated('a', 40),
      pendingRelease: pendingRelease,
    ),
  );
  final changelog = ChangelogManifest(iosReleases: releases);
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
        sha: repeated('b', 40),
        description: 'Old plan',
        bump: Bump.minor,
      );
      final root = await stateDirectory(
        version: '1.1.0',
        pendingRelease: true,
        releases: <String, ChangelogRelease>{
          '1.1.0': ChangelogRelease(
            version: '1.1.0',
            preparedAt: DateTime.utc(2026, 7, 25),
            baseSha: repeated('a', 40),
            headSha: repeated('b', 40),
            changes: <ConventionalChange>[oldChange],
          ),
        },
      );
      final receipt = File(candidatePath(root.path, Platform.ios, '1.1.0'));
      await receipt.writeAsString('{}\n');
      final nextChange = change(
        sha: repeated('c', 40),
        description: 'Breaking plan',
        bump: Bump.major,
      );
      final plan = ReleasePlan(
        platform: Platform.ios,
        currentVersion: '1.0.0',
        nextVersion: '2.0.0',
        bump: Bump.major,
        baseSha: repeated('a', 40),
        headSha: repeated('c', 40),
        changes: <ConventionalChange>[nextChange],
      );

      await applyReleasePlan(root.path, plan, DateTime.utc(2026, 7, 26));

      final changelog = await loadChangelog(root.path);
      expect(changelog.iosReleases.keys, <String>['2.0.0']);
      expect(await receipt.exists(), isFalse);
    });

    test(
      'preserves a tagged release when preparing the next version',
      () async {
        final releasedChange = change(
          sha: repeated('b', 40),
          description: 'Released plan',
          bump: Bump.minor,
        );
        final root = await stateDirectory(
          version: '1.1.0',
          pendingRelease: true,
          releases: <String, ChangelogRelease>{
            '1.1.0': ChangelogRelease(
              version: '1.1.0',
              preparedAt: DateTime.utc(2026, 7, 25),
              baseSha: repeated('a', 40),
              headSha: repeated('b', 40),
              changes: <ConventionalChange>[releasedChange],
            ),
          },
        );
        final receipt = File(candidatePath(root.path, Platform.ios, '1.1.0'));
        await receipt.writeAsString('{}\n');
        await git(root.path, const <String>['config', 'user.name', 'Test']);
        await git(root.path, const <String>[
          'config',
          'user.email',
          'test@example.com',
        ]);
        await git(root.path, const <String>['add', '.']);
        await git(root.path, const <String>[
          'commit',
          '-m',
          'chore(ios): release 1.1.0',
        ]);
        await git(root.path, const <String>['tag', 'ios-v1.1.0']);
        final head = await git(root.path, const <String>['rev-parse', 'HEAD']);
        final plan = ReleasePlan(
          platform: Platform.ios,
          currentVersion: '1.1.0',
          nextVersion: '1.2.0',
          bump: Bump.minor,
          baseSha: head,
          headSha: repeated('c', 40),
          changes: <ConventionalChange>[
            change(
              sha: repeated('c', 40),
              description: 'Next plan',
              bump: Bump.minor,
            ),
          ],
        );

        await applyReleasePlan(root.path, plan, DateTime.utc(2026, 7, 26));

        final changelog = await loadChangelog(root.path);
        expect(changelog.iosReleases.keys, <String>['1.1.0', '1.2.0']);
        expect(await receipt.exists(), isTrue);
      },
    );
  });
}
