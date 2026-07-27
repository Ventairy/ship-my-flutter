import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf/smf.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('CLI version matches the package version', () async {
    final pubspec = loadYaml(await File('pubspec.yaml').readAsString());
    expect(pubspec, isA<YamlMap>());
    expect((pubspec as YamlMap)['version'], smfVersion);
  });

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
        await runSmfCli(const <String>[
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

      expect(await runSmfCli(const <String>['validate'], io: io), 0);
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
      expect(await runSmfCli(const <String>['plan'], io: io), 0);
      expect(
        jsonDecode(output.removeLast()! as String),
        containsPair('nextVersion', '1.1.0'),
      );
      expect(errors, isEmpty);
    },
  );

  test('does not accept raw secrets as command-line options', () async {
    final errors = <Object?>[];
    final exitCode = await runSmfCli(
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

  test('prints command-specific help without executing the command', () async {
    final output = <Object?>[];
    final errors = <Object?>[];

    expect(
      await runSmfCli(
        const <String>['init', '--help'],
        io: CliIo(
          environment: const <String, String>{},
          workingDirectory: Directory.current.path,
          writeOutput: output.add,
          writeError: errors.add,
        ),
      ),
      0,
    );
    expect(output.single, contains('init options:'));
    expect(output.single, contains('--smf-path'));
    expect(errors, isEmpty);
  });
}
