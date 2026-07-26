import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

String configYaml({
  String buildCommand = 'flutter build ipa',
  List<String> groups = const <String>[],
  String mode = 'upload-only',
  String releaseType = 'manual',
  String? beforeCandidate,
}) =>
    '''
${beforeCandidate == null ? 'hooks: {}' : 'hooks:\n  before_candidate: "$beforeCandidate"'}
platforms:
  ios:
    project_path: .
    bundle_id: dev.example.app
    build_command: "$buildCommand"
    artifact_path: build/ios/ipa
    testflight:
      groups:
${groups.map((String value) => '        - "$value"').join('\n')}
    app_store:
      mode: $mode
      release_type: $releaseType
''';

void main() {
  group('candidate source fingerprint', () {
    test('supports repositories before initialization', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await git(root.path, const <String>['init', '-b', 'main']);
      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() {}\n');
      await git(root.path, const <String>['add', '.']);
      expect(await sourceFingerprint(root.path), matches(r'^[a-f0-9]{64}$'));
    });

    test('ignores human-editable notes and candidate receipts', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await git(root.path, const <String>['init', '-b', 'main']);
      final paths = resolveShipPaths(root.path);
      await Directory(paths.candidates).create(recursive: true);
      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() {}\n');
      await File(paths.storeReleaseNotes).writeAsString('{}\n');
      await File(paths.config).writeAsString(configYaml());
      final receipt = File(candidatePath(root.path, Platform.ios, '1.0.0'));
      await receipt.writeAsString('{}\n');
      await git(root.path, const <String>['add', '.']);

      final before = await sourceFingerprint(root.path);
      await File(paths.storeReleaseNotes).writeAsString('{"ios":{}}\n');
      await receipt.writeAsString('{"build":"1"}\n');
      await File(paths.config).writeAsString(
        configYaml(
          groups: const <String>['Internal'],
          mode: 'submit-for-review',
          releaseType: 'automatic',
        ),
      );
      expect(await sourceFingerprint(root.path), before);

      await File(
        paths.config,
      ).writeAsString(configYaml(buildCommand: 'fvm flutter build ipa'));
      expect(await sourceFingerprint(root.path), isNot(before));

      await File(
        paths.config,
      ).writeAsString(configYaml(beforeCandidate: 'dart run release:prepare'));
      expect(await sourceFingerprint(root.path), isNot(before));

      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() => run();\n');
      expect(await sourceFingerprint(root.path), isNot(before));
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
      final externalTarget = p.join(outside.path, 'external.dart');
      await File(externalTarget).writeAsString('external\n');
      await Link(p.join(root.path, 'external.dart')).create(externalTarget);
      await git(root.path, const <String>['add', 'external.dart']);

      await expectLater(
        sourceFingerprint(root.path),
        throwsA(
          isA<ShipError>().having(
            (ShipError error) => error.code,
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
          isA<ShipError>().having(
            (ShipError error) => error.code,
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
      await File(p.join(root.path, 'target.dart')).writeAsString('tracked\n');
      await Link(p.join(root.path, 'link.dart')).create('target.dart');
      await git(root.path, const <String>['add', 'target.dart', 'link.dart']);

      expect(await sourceFingerprint(root.path), matches(r'^[a-f0-9]{64}$'));
    });

    test('preserves leading whitespace in tracked file names', () async {
      final root = await Directory.systemTemp.createTemp('smf-fingerprint-');
      addTearDown(() => root.delete(recursive: true));
      await git(root.path, const <String>['init', '-b', 'main']);
      await File(p.join(root.path, ' leading.dart')).writeAsString('tracked\n');
      await git(root.path, const <String>['add', ' leading.dart']);

      expect(await sourceFingerprint(root.path), matches(r'^[a-f0-9]{64}$'));
    });
  });
}
