import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

void main() {
  test('runs a repository-owned executable with release context', () async {
    final root = await Directory.systemTemp.createTemp('smf-hook-');
    addTearDown(() => root.delete(recursive: true));
    final hookPath = p.join(root.path, 'release-hook.sh');
    await File(hookPath).writeAsString(
      <String>[
        '#!/bin/sh',
        'test "\$SHIP_MY_FLUTTER_PLATFORM" = "ios"',
        'test "\$SHIP_MY_FLUTTER_CURRENT_VERSION" = "1.0.0"',
        'test "\$SHIP_MY_FLUTTER_VERSION" = "1.1.0"',
        '',
      ].join('\n'),
    );
    await const SystemProcessRunner().run('/bin/chmod', <String>[
      '700',
      hookPath,
    ]);
    await git(root.path, const <String>['init', '-b', 'main']);
    await git(root.path, const <String>['add', 'release-hook.sh']);
    const config = ShipConfig(
      hooks: HooksConfig(beforeReleasePr: 'release-hook.sh'),
      ios: IosConfig(),
    );
    const plan = ReleasePlan(
      platform: Platform.ios,
      currentVersion: '1.0.0',
      nextVersion: '1.1.0',
      bump: Bump.minor,
      baseSha: 'base',
      headSha: 'head',
      changes: <ConventionalChange>[],
    );

    await runBeforeReleasePrHook(root.path, config, plan);
  });

  test('rejects a hook symlink that resolves outside the repository', () async {
    final root = await Directory.systemTemp.createTemp('smf-hook-root-');
    final outside = await Directory.systemTemp.createTemp('smf-hook-outside-');
    addTearDown(() async {
      await root.delete(recursive: true);
      await outside.delete(recursive: true);
    });
    final externalHook = p.join(outside.path, 'release-hook.sh');
    await File(externalHook).writeAsString('#!/bin/sh\nexit 0\n');
    await Link(p.join(root.path, 'release-hook.sh')).create(externalHook);
    const config = ShipConfig(
      hooks: HooksConfig(beforeReleasePr: 'release-hook.sh'),
      ios: IosConfig(),
    );
    const plan = ReleasePlan(
      platform: Platform.ios,
      currentVersion: '1.0.0',
      nextVersion: '1.1.0',
      bump: Bump.minor,
      baseSha: 'base',
      headSha: 'head',
      changes: <ConventionalChange>[],
    );

    await expectLater(
      runBeforeReleasePrHook(root.path, config, plan),
      throwsA(
        isA<ShipError>().having(
          (ShipError error) => error.code,
          'code',
          'UNSAFE_HOOK',
        ),
      ),
    );
  });

  test('rejects an untracked repository hook', () async {
    final root = await Directory.systemTemp.createTemp('smf-hook-untracked-');
    addTearDown(() => root.delete(recursive: true));
    await git(root.path, const <String>['init', '-b', 'main']);
    await File(
      p.join(root.path, 'release-hook.sh'),
    ).writeAsString('#!/bin/sh\nexit 0\n');
    const config = ShipConfig(
      hooks: HooksConfig(beforeReleasePr: 'release-hook.sh'),
      ios: IosConfig(),
    );
    const plan = ReleasePlan(
      platform: Platform.ios,
      currentVersion: '1.0.0',
      nextVersion: '1.1.0',
      bump: Bump.minor,
      baseSha: 'base',
      headSha: 'head',
      changes: <ConventionalChange>[],
    );

    await expectLater(
      runBeforeReleasePrHook(root.path, config, plan),
      throwsA(
        isA<ShipError>().having(
          (ShipError error) => error.code,
          'code',
          'UNSAFE_HOOK',
        ),
      ),
    );
  });
}
