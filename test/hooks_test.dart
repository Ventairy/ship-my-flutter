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
}
