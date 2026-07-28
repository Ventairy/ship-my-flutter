import 'dart:io';

import 'package:smf_cli/src/upgrade.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('embedded CLI version matches the package version', () async {
    final pubspec =
        loadYaml(
              await File('pubspec.yaml').readAsString(),
            )
            as YamlMap;

    expect(smfCliVersion, pubspec['version']);
  });

  test('reports a newer published version', () async {
    final service = SmfUpgradeService(
      latestVersionLoader: () async => '0.2.0',
      installer: (_, _) async => ProcessResult(1, 0, '', ''),
    );

    expect(await service.newerVersion(), '0.2.0');
  });

  test('does not reinstall an up-to-date CLI', () async {
    var installed = false;
    final service = SmfUpgradeService(
      latestVersionLoader: () async => smfCliVersion,
      installer: (_, _) async {
        installed = true;
        return ProcessResult(1, 0, '', '');
      },
    );

    expect(await service.upgrade(), <String, Object?>{
      'upgraded': false,
      'version': smfCliVersion,
      'message': 'SMF is already up to date.',
    });
    expect(installed, isFalse);
  });

  test('installs the exact latest published version', () async {
    String? executable;
    List<String>? arguments;
    final service = SmfUpgradeService(
      latestVersionLoader: () async => '0.2.0',
      installer: (value, values) async {
        executable = value;
        arguments = values;
        return ProcessResult(1, 0, '', '');
      },
    );

    expect(await service.upgrade(), <String, Object?>{
      'upgraded': true,
      'previousVersion': smfCliVersion,
      'version': '0.2.0',
    });
    expect(executable, 'dart');
    expect(arguments, <String>[
      'install',
      'smf_cli',
      '0.2.0',
      '--overwrite',
    ]);
  });

  test('maps unavailable and failed upgrades to actionable errors', () async {
    final unavailable = SmfUpgradeService(
      latestVersionLoader: () async => null,
      installer: (_, _) async => ProcessResult(1, 0, '', ''),
    );
    await expectLater(
      unavailable.upgrade(),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'UPGRADE_CHECK_FAILED',
        ),
      ),
    );

    final malformed = SmfUpgradeService(
      latestVersionLoader: () async => 'not-a-version',
      installer: (_, _) async => ProcessResult(1, 0, '', ''),
    );
    await expectLater(
      malformed.upgrade(),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'UPGRADE_CHECK_FAILED',
        ),
      ),
    );

    final failed = SmfUpgradeService(
      latestVersionLoader: () async => '0.2.0',
      installer: (_, _) async => ProcessResult(1, 1, '', 'failed'),
    );
    await expectLater(
      failed.upgrade(),
      throwsA(
        isA<SmfError>()
            .having((error) => error.code, 'code', 'UPGRADE_FAILED')
            .having(
              (error) => error.message,
              'message',
              contains('dart install smf_cli --overwrite'),
            ),
      ),
    );

    final missingDart = SmfUpgradeService(
      latestVersionLoader: () async => '0.2.0',
      installer: (_, _) async => throw const ProcessException('dart', <String>[]),
    );
    await expectLater(
      missingDart.upgrade(),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'UPGRADE_FAILED',
        ),
      ),
    );
  });
}
