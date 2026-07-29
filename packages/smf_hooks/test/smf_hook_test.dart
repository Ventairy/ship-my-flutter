import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
    'when store notes exist, it should replace them atomically and preserve their metadata',
    () async {
      final root = await Directory.systemTemp.createTemp('smf-hooks-');
      addTearDown(() => root.delete(recursive: true));
      await Directory(p.join(root.path, 'smf')).create();
      final notesPath = p.join(root.path, 'smf', 'notes.json');
      await File(notesPath).writeAsString(
        jsonEncode(<String, Object?>{
          'android': <String, Object?>{
            '1.0.0': <String, Object?>{'pt-BR': 'Nota existente'},
          },
        }),
      );
      if (!Platform.isWindows) {
        final result = await Process.run('/bin/chmod', <String>[
          '640',
          notesPath,
        ]);
        expect(result.exitCode, 0);
      }
      final contextPath = p.join(root.path, 'context.json');
      final resultPath = p.join(root.path, 'result.json');
      final observationPath = p.join(root.path, 'observation.json');
      await File(contextPath).writeAsString(
        jsonEncode(<String, Object?>{
          'schemaVersion': 1,
          'phase': 'before_create_pr',
          'storeReleaseNotesFile': notesPath,
          'iosRelease': <String, Object?>{
            'nextVersion': '1.1.0',
            'changes': <Object?>[
              <String, Object?>{
                'type': 'feat',
                'scope': 'ios',
                'description': 'Improve search',
                'body': 'Show nearby work sooner.',
              },
            ],
          },
          'androidRelease': <String, Object?>{
            'nextVersion': '2.0.0',
            'changes': <Object?>[
              <String, Object?>{
                'type': 'fix',
                'scope': 'android',
                'description': 'Improve startup',
                'body': null,
              },
            ],
          },
        }),
      );
      final process = await Process.run(
        Platform.resolvedExecutable,
        <String>[
          'run',
          'test/fixtures/write_store_release_notes_hook.dart',
        ],
        environment: <String, String>{
          'SMF_HOOK_CONTEXT_PATH': contextPath,
          'SMF_HOOK_RESULT_PATH': resultPath,
          'SMF_HOOK_TEST_OBSERVATION_PATH': observationPath,
        },
      );
      expect(process.exitCode, 0, reason: process.stderr as String);
      final observation = jsonDecode(await File(observationPath).readAsString()) as Map<String, Object?>;
      expect(observation, <String, Object?>{
        'iosVersion': '1.1.0',
        'iosCharacterLimit': 4000,
        'changeType': 'feat',
        'changeScope': 'ios',
        'changeDescription': 'Improve search',
        'changeBody': 'Show nearby work sooner.',
        'androidVersion': '2.0.0',
        'androidCharacterLimit': 500,
        'androidDescription': 'Improve startup',
      });
      final notes = jsonDecode(await File(notesPath).readAsString()) as Map<String, Object?>;
      expect(
        ((notes['ios']! as Map<String, Object?>)['1.1.0']! as Map<String, Object?>)['pt-BR'],
        'Novidades locais.',
      );
      expect(
        ((notes['android']! as Map<String, Object?>)['2.0.0']! as Map<String, Object?>)['pt-BR'],
        'Novidades locais no Android.',
      );
      expect(
        ((notes['android']! as Map<String, Object?>)['1.0.0']! as Map<String, Object?>)['pt-BR'],
        'Nota existente',
      );
      expect(jsonDecode(await File(resultPath).readAsString()), <String, Object?>{
        'schemaVersion': 1,
      });
      expect(
        Directory(p.dirname(notesPath)).listSync().where((entry) => entry.path.contains('.smf-write-')),
        isEmpty,
      );
      if (!Platform.isWindows) {
        expect((await File(notesPath).stat()).mode & 0x1ff, 0x1a0);
      }
    },
  );

  test('runCommand fails when the command exits unsuccessfully', () async {
    final root = await Directory.systemTemp.createTemp('smf-hooks-');
    addTearDown(() => root.delete(recursive: true));
    final contextPath = p.join(root.path, 'context.json');
    final resultPath = p.join(root.path, 'result.json');
    await File(contextPath).writeAsString(
      jsonEncode(<String, Object?>{
        'schemaVersion': 1,
        'phase': 'before_build',
        'repositoryRoot': root.path,
      }),
    );

    final process = await Process.run(
      Platform.resolvedExecutable,
      <String>['run', 'test/fixtures/failing_before_build_hook.dart'],
      environment: <String, String>{
        'SMF_HOOK_CONTEXT_PATH': contextPath,
        'SMF_HOOK_RESULT_PATH': resultPath,
      },
    );
    expect(process.exitCode, isNot(0));
    expect(
      await File(p.join(root.path, 'pwd.txt')).readAsString(),
      '${await root.resolveSymbolicLinks()}\n',
    );
  });
}
