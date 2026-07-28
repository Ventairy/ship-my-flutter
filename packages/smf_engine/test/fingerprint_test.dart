import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

String configYaml({
  String appId = 'example',
  String buildCommand = 'flutter build ipa --release',
  String? flavor,
  List<String> groups = const <String>[],
  List<String> releaseTriggerPaths = const <String>[],
  String? shipTarget,
}) =>
    '''
schema_version: 3
app_id: $appId
${flavor == null ? '' : 'flavor: $flavor\n'}${releaseTriggerPaths.isEmpty ? '' : 'release_trigger_paths:\n${releaseTriggerPaths.map((path) => '  - $path').join('\n')}\n'}platforms:
  ios:
    bundle_id: dev.example.app
    build_command: "$buildCommand"
    ipa_output_path: build/ios/ipa
    app_store:
      release_candidate:
        target: internal-testing
        groups:
${groups.map((value) => '          - "$value"').join('\n')}
        wait_timeout_minutes: 45
${shipTarget == null ? '' : '      ship:\n        target: $shipTarget\n'}
''';

void main() {
  group('candidate source fingerprint', () {
    test('requires an initialized SMF app', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() {}\n');
      await GitClient(root: root.path).run(const <String>['add', '.']);
      await expectLater(
        SourceFingerprint.calculate(root.path),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'SMF_NOT_FOUND',
          ),
        ),
      );
    });

    test('ignores human-editable notes and candidate receipts', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      final paths = SmfPaths.resolve(root.path);
      await Directory(paths.candidates).create();
      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() {}\n');
      await File(paths.storeReleaseNotes).writeAsString('{}\n');
      final receipt = File(
        paths.candidatePath(platform: Platform.ios, version: '1.0.0'),
      );
      await receipt.writeAsString('{}\n');
      await GitClient(root: root.path).run(const <String>['add', '.']);

      final before = await SourceFingerprint.calculate(root.path);
      await File(paths.storeReleaseNotes).writeAsString('{"ios":{}}\n');
      await receipt.writeAsString('{"build":"1"}\n');
      await File(paths.config).writeAsString(
        configYaml(
          groups: const <String>['Internal'],
          shipTarget: 'production',
        ),
      );
      expect(await SourceFingerprint.calculate(root.path), before);

      await File(
        paths.config,
      ).writeAsString(configYaml(buildCommand: 'fvm flutter build ipa'));
      expect(await SourceFingerprint.calculate(root.path), isNot(before));

      await File(paths.config).writeAsString(configYaml(flavor: 'production'));
      expect(await SourceFingerprint.calculate(root.path), isNot(before));

      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() => run();\n');
      expect(await SourceFingerprint.calculate(root.path), isNot(before));
    });

    test('normalizes omitted IPA output defaults', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      final paths = SmfPaths.resolve(root.path);
      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() {}\n');
      await GitClient(root: root.path).run(const <String>['add', '.']);

      final explicitDefaults = await SourceFingerprint.calculate(root.path);
      await File(paths.config).writeAsString(
        configYaml().replaceFirst('    ipa_output_path: build/ios/ipa\n', ''),
      );

      expect(await SourceFingerprint.calculate(root.path), explicitDefaults);
    });

    test('distinguishes automatic and explicit build commands', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      final paths = SmfPaths.resolve(root.path);
      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() {}\n');
      await GitClient(root: root.path).run(const <String>['add', '.']);

      final explicitCommand = await SourceFingerprint.calculate(root.path);
      await File(paths.config).writeAsString(
        configYaml().replaceFirst(
          '    build_command: "flutter build ipa --release"\n',
          '',
        ),
      );

      expect(await SourceFingerprint.calculate(root.path), isNot(explicitCommand));
    });

    test('rejects tracked symlinks to hidden build inputs', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      final outside = await Directory.systemTemp.createTemp(
        'smf-fingerprint-outside-',
      );
      addTearDown(() async {
        await root.delete(recursive: true);
        await outside.delete(recursive: true);
      });
      await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      final externalTarget = p.join(outside.path, 'external.dart');
      await File(externalTarget).writeAsString('external\n');
      await Link(p.join(root.path, 'external.dart')).create(externalTarget);
      await GitClient(root: root.path).run(const <String>['add', 'external.dart']);

      await expectLater(
        SourceFingerprint.calculate(root.path),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'SOURCE_SYMLINK_ESCAPE',
          ),
        ),
      );

      await Link(p.join(root.path, 'external.dart')).delete();
      final ignoredTarget = p.join(root.path, 'generated.dart');
      await File(ignoredTarget).writeAsString('ignored\n');
      await File(
        p.join(root.path, '.gitignore'),
      ).writeAsString('generated.dart\n');
      await Link(p.join(root.path, 'external.dart')).create('generated.dart');
      await GitClient(root: root.path).run(const <String>[
        'add',
        '.gitignore',
        'external.dart',
      ]);

      await expectLater(
        SourceFingerprint.calculate(root.path),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'SOURCE_SYMLINK_UNTRACKED',
          ),
        ),
      );
    });

    test('accepts a tracked symlink to another tracked file', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      await File(p.join(root.path, 'target.dart')).writeAsString('tracked\n');
      await Link(p.join(root.path, 'link.dart')).create('target.dart');
      await GitClient(root: root.path).run(const <String>['add', 'target.dart', 'link.dart']);

      expect(await SourceFingerprint.calculate(root.path), matches(r'^[a-f0-9]{64}$'));
    });

    test(
      'isolates sibling apps and includes configured shared inputs',
      () async {
        final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
        addTearDown(() => root.delete(recursive: true));
        await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
        final customer = p.join(root.path, 'apps', 'customer');
        final driver = p.join(root.path, 'apps', 'driver');
        final shared = p.join(root.path, 'packages', 'shared_models');
        await Directory(p.join(customer, 'smf')).create(recursive: true);
        await Directory(driver).create(recursive: true);
        await Directory(shared).create(recursive: true);
        await File(
          p.join(customer, 'smf', 'config.yaml'),
        ).writeAsString(
          configYaml(
            appId: 'customer',
            releaseTriggerPaths: const <String>['packages/shared_models/**'],
          ),
        );
        final customerSource = File(p.join(customer, 'lib', 'main.dart'));
        await customerSource.parent.create(recursive: true);
        await customerSource.writeAsString('customer\n');
        final driverSource = File(p.join(driver, 'lib', 'main.dart'));
        await driverSource.parent.create(recursive: true);
        await driverSource.writeAsString('driver\n');
        final sharedSource = File(p.join(shared, 'lib', 'model.dart'));
        await sharedSource.parent.create(recursive: true);
        await sharedSource.writeAsString('shared\n');
        await GitClient(root: root.path).run(const <String>['add', '.']);

        final initial = await SourceFingerprint.calculate(
          p.join(customer, 'smf'),
        );
        await driverSource.writeAsString('changed driver\n');
        expect(await SourceFingerprint.calculate(p.join(customer, 'smf')), initial);

        await sharedSource.writeAsString('changed shared\n');
        expect(
          await SourceFingerprint.calculate(p.join(customer, 'smf')),
          isNot(initial),
        );
      },
    );

    test('preserves leading whitespace in tracked file names', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await GitClient(root: root.path).run(const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      await File(p.join(root.path, ' leading.dart')).writeAsString('tracked\n');
      await GitClient(root: root.path).run(const <String>['add', ' leading.dart']);

      expect(await SourceFingerprint.calculate(root.path), matches(r'^[a-f0-9]{64}$'));
    });
  });
}
