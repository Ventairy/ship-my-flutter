import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

void main() {
  test(
    'initializes, validates, and plans through the public Dart CLI',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-cli-');
      addTearDown(() => root.delete(recursive: true));
      await Directory(p.join(root.path, 'ios')).create();
      await File(
        p.join(root.path, 'pubspec.yaml'),
      ).writeAsString('name: example\nversion: 1.0.0+1\n');
      await File(p.join(root.path, 'pubspec.lock')).writeAsString('# lock\n');
      await git(root.path, const <String>['init', '-b', 'main']);
      await git(root.path, const <String>['config', 'user.name', 'Test']);
      await git(root.path, const <String>[
        'config',
        'user.email',
        'test@example.com',
      ]);
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>['commit', '-m', 'chore: bootstrap']);

      final output = <Object?>[];
      final errors = <Object?>[];
      final io = CliIo(
        environment: const <String, String>{},
        workingDirectory: root.path,
        writeOutput: output.add,
        writeError: errors.add,
      );
      expect(
        await runShipMyFlutterCli(const <String>[
          'init',
          '--bundle-id',
          'dev.example.app',
        ], io: io),
        0,
      );
      expect(
        jsonDecode(output.removeLast()! as String),
        containsPair('initialized', true),
      );
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>[
        'commit',
        '-m',
        'chore: configure releases',
      ]);

      expect(await runShipMyFlutterCli(const <String>['validate'], io: io), 0);
      expect(jsonDecode(output.removeLast()! as String), <String, Object?>{
        'valid': true,
      });

      await File(p.join(root.path, 'feature.txt')).writeAsString('feature\n');
      await git(root.path, const <String>['add', '.']);
      await git(root.path, const <String>[
        'commit',
        '-m',
        'feat(ios): public CLI',
      ]);
      expect(await runShipMyFlutterCli(const <String>['plan'], io: io), 0);
      expect(
        jsonDecode(output.removeLast()! as String),
        containsPair('nextVersion', '1.1.0'),
      );
      expect(errors, isEmpty);
    },
  );

  test('does not accept raw secrets as command-line options', () async {
    final errors = <Object?>[];
    final exitCode = await runShipMyFlutterCli(
      const <String>['open-pr', '--github-token', 'visible-secret'],
      io: CliIo(
        environment: const <String, String>{},
        workingDirectory: Directory.current.path,
        writeOutput: (_) {},
        writeError: errors.add,
      ),
    );
    expect(exitCode, 64);
    expect(errors.join('\n'), isNot(contains('visible-secret')));
  });
}
