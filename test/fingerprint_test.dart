import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

String configYaml({
  List<String> buildArgs = const <String>[],
  List<String> groups = const <String>[],
  String mode = 'upload-only',
  String releaseType = 'manual',
}) =>
    '''
platforms:
  ios:
    projectPath: .
    bundleId: dev.example.app
    buildArgs:
${buildArgs.map((String value) => '      - "$value"').join('\n')}
    testflight:
      groups:
${groups.map((String value) => '        - "$value"').join('\n')}
    appStore:
      mode: $mode
      releaseType: $releaseType
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

      await File(paths.config).writeAsString(
        configYaml(buildArgs: const <String>['--dart-define=ENV=production']),
      );
      expect(await sourceFingerprint(root.path), isNot(before));

      await File(
        p.join(root.path, 'lib.dart'),
      ).writeAsString('void main() => run();\n');
      expect(await sourceFingerprint(root.path), isNot(before));
    });
  });
}
