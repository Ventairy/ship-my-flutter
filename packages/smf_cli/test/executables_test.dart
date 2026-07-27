import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_cli/src/executables.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('publishes one installed smf entrypoint', () async {
    final pubspec =
        loadYaml(await File('pubspec.yaml').readAsString()) as YamlMap;
    expect(pubspec['executables'], <Object?, Object?>{'smf': 'smf'});
    expect(await File('bin/smf.dart').exists(), isTrue);
  });

  test('CLI commands initialize, validate, and plan', () async {
    final root = await Directory.systemTemp.createTemp('smf-executable-');
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
    final io = ExecutableIo(
      environment: const <String, String>{},
      workingDirectory: root.path,
      writeOutput: output.add,
      writeError: errors.add,
    );
    expect(
      await runInitExecutable(const <String>[
        '--bundle-id',
        'dev.example.app',
      ], io: io),
      0,
    );
    expect(
      jsonDecode(output.removeLast()! as String),
      containsPair('initialized', true),
    );
    final configPath = p.join(root.path, 'smf', 'config.yaml');
    final config = '${await File(configPath).readAsString()}# preserved\n';
    await File(configPath).writeAsString(config);
    final workflowPath = p.join(root.path, '.github', 'workflows', 'smf.yml');
    await File(workflowPath).writeAsString('stale workflow\n');
    expect(
      await runInitExecutable(const <String>['--workflow-only'], io: io),
      0,
    );
    expect(
      jsonDecode(output.removeLast()! as String),
      containsPair('workflowUpdated', true),
    );
    expect(await File(configPath).readAsString(), config);
    expect(
      await File(workflowPath).readAsString(),
      await File('../smf_engine/templates/smf.yml').readAsString(),
    );
    await git(root.path, const <String>['add', '.']);
    await git(root.path, const <String>[
      'commit',
      '-m',
      'chore: configure releases',
    ]);

    expect(await runValidateExecutable(const <String>[], io: io), 0);
    expect(jsonDecode(output.removeLast()! as String), <String, Object?>{
      'valid': true,
    });

    await File(p.join(root.path, 'feature.txt')).writeAsString('feature\n');
    await git(root.path, const <String>['add', '.']);
    await git(root.path, const <String>[
      'commit',
      '-m',
      'feat(ios): project executable',
    ]);
    expect(await runPlanExecutable(const <String>[], io: io), 0);
    expect(
      jsonDecode(output.removeLast()! as String),
      containsPair('nextVersion', '1.1.0'),
    );
    expect(errors, isEmpty);
  });

  test('does not accept raw secrets as command-line options', () async {
    final errors = <Object?>[];
    final exitCode = await runOpenPrExecutable(
      const <String>['--github-token', 'visible-secret'],
      io: ExecutableIo(
        environment: const <String, String>{},
        workingDirectory: Directory.current.path,
        writeOutput: (_) {},
        writeError: errors.add,
      ),
    );
    expect(exitCode, 64);
    expect(errors.join('\n'), isNot(contains('visible-secret')));
  });

  test(
    'prints executable-specific help without executing the operation',
    () async {
      final output = <Object?>[];
      final errors = <Object?>[];

      expect(
        await runInitExecutable(
          const <String>['--help'],
          io: ExecutableIo(
            environment: const <String, String>{},
            workingDirectory: Directory.current.path,
            writeOutput: output.add,
            writeError: errors.add,
          ),
        ),
        0,
      );
      expect(output.single, contains('Usage: smf init [options]'));
      expect(output.single, contains('--smf-path'));
      expect(errors, isEmpty);
    },
  );
}
