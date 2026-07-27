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
  }
}

void main() {
  test('decodes the typed hook protocol and writes its result', () async {
    final root = await Directory.systemTemp.createTemp('smf-hooks-');
    addTearDown(() => root.delete(recursive: true));
    final contextPath = p.join(root.path, 'context.json');
    final resultPath = p.join(root.path, 'result.json');
    await File(contextPath).writeAsString(
      jsonEncode(<String, Object?>{
        'schemaVersion': 1,
        'phase': 'before_create_pr',
        'platform': 'ios',
        'platformVersion': '1.1.0',
        'repositoryRoot': root.path,
        'appRoot': root.path,
        'smfDirectory': p.join(root.path, 'smf'),
        'configFile': p.join(root.path, 'smf', 'config.yaml'),
        'changelogFile': p.join(root.path, 'smf', 'changelog.json'),
        'storeReleaseNotesFile': p.join(root.path, 'smf', 'notes.json'),
        'flavor': null,
        'currentPlatformVersion': '1.0.0',
        'releasePlan': <String, Object?>{
          'platform': 'ios',
          'currentVersion': '1.0.0',
          'nextVersion': '1.1.0',
          'bump': 'minor',
          'baseSha': 'base',
          'headSha': 'head',
          'changes': <Object?>[],
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

    expect(hook.received!.releasePlan.nextVersion, '1.1.0');
    expect(jsonDecode(await File(resultPath).readAsString()), <String, Object?>{
      'schemaVersion': 1,
      'commitChanges': true,
    });
  });
}
