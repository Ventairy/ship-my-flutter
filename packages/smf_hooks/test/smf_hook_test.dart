import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_hooks/smf_hooks.dart';
import 'package:test/test.dart';

final class _Hook extends SmfHook {
  SmfBeforeCreatePrContext? received;

  @override
  Future<void> run(SmfBeforeCreatePrContext context) async {
    received = context;
    context.release.ios!.storeReleaseNotes.write(
      locale: 'pt-BR',
      message: 'Novidades locais.',
    );
    context.release.android!.storeReleaseNotes.write(
      locale: 'pt-BR',
      message: 'Novidades locais no Android.',
    );
  }
}

final class _FailingHook extends SmfHook {
  @override
  Future<void> run(SmfBeforeBuildContext context) async {
    await context.runCommand('pwd > pwd.txt; exit 7', root: true);
  }
}

void main() {
  test('decodes the typed hook protocol and writes its result', () async {
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
    final contextPath = p.join(root.path, 'context.json');
    final resultPath = p.join(root.path, 'result.json');
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
    final hook = _Hook();

    await runSmfHook(
      hook,
      environment: <String, String>{
        'SMF_HOOK_CONTEXT_PATH': contextPath,
        'SMF_HOOK_RESULT_PATH': resultPath,
      },
    );

    expect(hook.received!.release.ios!.nextVersion, '1.1.0');
    expect(
      hook.received!.release.ios!.storeReleaseNotes.characterLimit,
      4000,
    );
    final change = hook.received!.release.ios!.changes.single;
    expect(change.type, 'feat');
    expect(change.scope, 'ios');
    expect(change.description, 'Improve search');
    expect(change.body, 'Show nearby work sooner.');
    expect(
      () => hook.received!.release.ios!.changes.clear(),
      throwsUnsupportedError,
    );
    expect(hook.received!.release.android!.nextVersion, '2.0.0');
    expect(
      hook.received!.release.android!.storeReleaseNotes.characterLimit,
      500,
    );
    expect(
      hook.received!.release.android!.changes.single.description,
      'Improve startup',
    );
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
  });

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

    await expectLater(
      runSmfHook(
        _FailingHook(),
        environment: <String, String>{
          'SMF_HOOK_CONTEXT_PATH': contextPath,
          'SMF_HOOK_RESULT_PATH': resultPath,
        },
      ),
      throwsA(isA<ProcessException>()),
    );
    expect(
      await File(p.join(root.path, 'pwd.txt')).readAsString(),
      '${await root.resolveSymbolicLinks()}\n',
    );
  });
}
