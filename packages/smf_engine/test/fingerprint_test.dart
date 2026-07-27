import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

String configYaml({
  String buildCommand = 'flutter build ipa --release',
  String? flavor,
  List<String> groups = const <String>[],
  String mode = 'upload',
}) =>
    '''
schema_version: 1
${flavor == null ? '' : 'flavor: $flavor\n'}platforms:
  ios:
    bundle_id: dev.example.app
    build_command: "$buildCommand"
    ipa_output_path: build/ios/ipa
    testflight:
      groups:
${groups.map((value) => '        - "$value"').join('\n')}
    app_store:
      mode: $mode
''';

void main() {
  group('candidate source fingerprint', () {
    test('requires an initialized SMF app', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await git(root.path, const <String>['init', '-b', 'main']);
      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() {}\n');
      await git(root.path, const <String>['add', '.']);
      await expectLater(
        sourceFingerprint(root.path),
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
      await git(root.path, const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      final paths = resolveSmfPaths(root.path);
      await Directory(paths.candidates).create();
      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() {}\n');
      await File(paths.storeReleaseNotes).writeAsString('{}\n');
      final receipt = File(candidatePath(root.path, Platform.ios, '1.0.0'));
      await receipt.writeAsString('{}\n');
      await git(root.path, const <String>['add', '.']);

      final before = await sourceFingerprint(root.path);
      await File(paths.storeReleaseNotes).writeAsString('{"ios":{}}\n');
      await receipt.writeAsString('{"build":"1"}\n');
      await File(paths.config).writeAsString(
        configYaml(groups: const <String>['Internal'], mode: 'auto'),
      );
      expect(await sourceFingerprint(root.path), before);

      await File(
        paths.config,
      ).writeAsString(configYaml(buildCommand: 'fvm flutter build ipa'));
      expect(await sourceFingerprint(root.path), isNot(before));

      await File(paths.config).writeAsString(configYaml(flavor: 'production'));
      expect(await sourceFingerprint(root.path), isNot(before));

      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() => run();\n');
      expect(await sourceFingerprint(root.path), isNot(before));
    });

    test('normalizes omitted IPA output defaults', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await git(root.path, const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      final paths = resolveSmfPaths(root.path);
      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() {}\n');
      await git(root.path, const <String>['add', '.']);

      final explicitDefaults = await sourceFingerprint(root.path);
      await File(paths.config).writeAsString(
        configYaml().replaceFirst('    ipa_output_path: build/ios/ipa\n', ''),
      );

      expect(await sourceFingerprint(root.path), explicitDefaults);
    });

    test('distinguishes automatic and explicit build commands', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await git(root.path, const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      final paths = resolveSmfPaths(root.path);
      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() {}\n');
      await git(root.path, const <String>['add', '.']);

      final explicitCommand = await sourceFingerprint(root.path);
      await File(paths.config).writeAsString(
        configYaml().replaceFirst(
          '    build_command: "flutter build ipa --release"\n',
          '',
        ),
      );

      expect(await sourceFingerprint(root.path), isNot(explicitCommand));
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
      await git(root.path, const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      final externalTarget = p.join(outside.path, 'external.dart');
      await File(externalTarget).writeAsString('external\n');
      await Link(p.join(root.path, 'external.dart')).create(externalTarget);
      await git(root.path, const <String>['add', 'external.dart']);

      await expectLater(
        sourceFingerprint(root.path),
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
      await git(root.path, const <String>[
        'add',
        '.gitignore',
        'external.dart',
      ]);

      await expectLater(
        sourceFingerprint(root.path),
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
      await git(root.path, const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      await File(p.join(root.path, 'target.dart')).writeAsString('tracked\n');
      await Link(p.join(root.path, 'link.dart')).create('target.dart');
      await git(root.path, const <String>['add', 'target.dart', 'link.dart']);

      expect(await sourceFingerprint(root.path), matches(r'^[a-f0-9]{64}$'));
    });

    test('preserves leading whitespace in tracked file names', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await git(root.path, const <String>['init', '-b', 'main']);
      final smf = Directory(p.join(root.path, 'smf'));
      await smf.create();
      await File(p.join(smf.path, 'config.yaml')).writeAsString(configYaml());
      await File(p.join(root.path, ' leading.dart')).writeAsString('tracked\n');
      await git(root.path, const <String>['add', ' leading.dart']);

      expect(await sourceFingerprint(root.path), matches(r'^[a-f0-9]{64}$'));
    });
  });
}
