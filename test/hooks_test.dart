import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

import 'support/recording_process.dart';

void main() {
  test('runs a release PR shell command with release context', () async {
    final root = await Directory.systemTemp.createTemp('smf-hook-');
    addTearDown(() => root.delete(recursive: true));
    final runner = RecordingProcessRunner();
    const command = 'fvm dart run release:generate_store_release_notes';
    const config = ShipConfig(
      hooks: HooksConfig(beforeReleasePr: command),
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

    await runBeforeReleasePrHook(
      root.path,
      config,
      plan,
      processRunner: runner,
    );

    final invocation = runner.invocations.single;
    expect(invocation.executable, '/bin/bash');
    expect(invocation.arguments.last, command);
    expect(invocation.options.workingDirectory, root.path);
    expect(
      invocation.options.environment,
      containsPair('SHIP_MY_FLUTTER_VERSION', '1.1.0'),
    );
  });

  test('runs before_candidate from the repository root', () async {
    final root = await Directory.systemTemp.createTemp('smf-hook-');
    addTearDown(() => root.delete(recursive: true));
    final runner = RecordingProcessRunner();
    const config = ShipConfig(
      hooks: HooksConfig(beforeCandidate: 'fvm dart run release:prepare_ios'),
      ios: IosConfig(projectPath: 'apps/mobile'),
    );

    await runBeforeCandidateHook(
      root.path,
      config,
      '2.3.0',
      processRunner: runner,
    );

    final invocation = runner.invocations.single;
    expect(invocation.options.workingDirectory, root.path);
    expect(
      invocation.options.environment,
      containsPair('SHIP_MY_FLUTTER_PROJECT_PATH', 'apps/mobile'),
    );
    expect(
      invocation.options.environment,
      containsPair('SHIP_MY_FLUTTER_VERSION', '2.3.0'),
    );
  });

  test('supports ordinary shell composition', () async {
    final root = await Directory.systemTemp.createTemp('smf-hook-');
    addTearDown(() => root.delete(recursive: true));
    final output = p.join(root.path, 'result.txt');
    const config = ShipConfig(
      hooks: HooksConfig(
        beforeCandidate:
            'printf first > result.txt && printf second >> '
            'result.txt',
      ),
      ios: IosConfig(),
    );

    await runBeforeCandidateHook(root.path, config, '1.0.0');

    expect(await File(output).readAsString(), 'firstsecond');
  });
}
