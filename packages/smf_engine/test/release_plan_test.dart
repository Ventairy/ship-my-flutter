import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

Future<(Directory, String)> repository() async {
  final directory = await Directory.systemTemp.createTemp('smf-plan-');
  addTearDown(() => directory.delete(recursive: true));
  await git(directory.path, const <String>['init', '-b', 'main']);
  await git(directory.path, const <String>['config', 'user.name', 'Test']);
  await git(directory.path, const <String>[
    'config',
    'user.email',
    'test@example.com',
  ]);
  await File(p.join(directory.path, 'app.txt')).writeAsString('baseline\n');
  await git(directory.path, const <String>['add', '.']);
  await git(directory.path, const <String>['commit', '-m', 'chore: bootstrap']);
  return (
    directory,
    await git(directory.path, const <String>['rev-parse', 'HEAD']),
  );
}

Future<void> commit(String root, String message, String content) async {
  await File(p.join(root, 'app.txt')).writeAsString(content);
  await git(root, const <String>['add', '.']);
  await git(root, <String>['commit', '-m', message]);
}

SmfManifest manifest(
  String version,
  String baselineSha, {
  bool pendingRelease = false,
}) => SmfManifest(
  ios: PlatformManifest(
    version: version,
    baselineSha: baselineSha,
    pendingRelease: pendingRelease,
  ),
);

void main() {
  group('release planning', () {
    test('bumps iOS independently and excludes Android-only changes', () async {
      final (directory, baselineSha) = await repository();
      await commit(directory.path, 'feat(ios): add widgets', 'ios\n');
      await commit(
        directory.path,
        'fix(android): repair back button',
        'android\n',
      );

      final plan = await createReleasePlan(
        directory.path,
        manifest('1.2.3', baselineSha),
        Platform.ios,
      );

      expect(plan?.nextVersion, '1.3.0');
      expect(
        plan?.changes.map((ConventionalChange change) => change.description),
        <String>['add widgets'],
      );
    });

    test('uses the platform tag as the next release baseline', () async {
      final (directory, baselineSha) = await repository();
      await commit(directory.path, 'feat: already released', 'released\n');
      await git(directory.path, <String>[
        'tag',
        releaseTag(Platform.ios, '2.0.0'),
      ]);
      await commit(directory.path, 'fix: new patch', 'patch\n');
      final state = manifest('2.0.0', baselineSha, pendingRelease: true);

      final plan = await createReleasePlan(directory.path, state, Platform.ios);

      expect(plan?.nextVersion, '2.0.1');
      expect(plan?.changes, hasLength(1));
      expect(
        await releaseNeedsPromotion(directory.path, state, Platform.ios),
        isFalse,
      );
    });

    test('recognizes a merged pending release without a tag', () async {
      final (directory, baselineSha) = await repository();
      expect(
        await releaseNeedsPromotion(
          directory.path,
          manifest('1.0.0', baselineSha, pendingRelease: true),
          Platform.ios,
        ),
        isTrue,
      );
    });

    test('returns no plan for non-releasable commits', () async {
      final (directory, baselineSha) = await repository();
      await commit(directory.path, 'chore: update tooling', 'tooling\n');
      expect(
        await createReleasePlan(
          directory.path,
          manifest('1.0.0', baselineSha),
          Platform.ios,
        ),
        isNull,
      );
    });

    test('honors an explicit Release-As version', () async {
      final (directory, baselineSha) = await repository();
      await commit(
        directory.path,
        'chore(ios): prepare migration\n\nRelease-As-ios: 4.0.0',
        'migration\n',
      );
      final plan = await createReleasePlan(
        directory.path,
        manifest('1.0.0', baselineSha),
        Platform.ios,
      );
      expect(plan?.nextVersion, '4.0.0');
    });
  });
}
