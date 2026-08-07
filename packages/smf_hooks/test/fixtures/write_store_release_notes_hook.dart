import 'dart:convert';
import 'dart:io';

import 'package:smf_hooks/smf_hooks.dart';

final class WriteStoreReleaseNotesHook extends SmfHook {
  @override
  Future<void> run(SmfBeforeCreatePrContext context) async {
    final ios = context.release.ios!;
    final android = context.release.android!;
    await File(
      Platform.environment['SMF_HOOK_TEST_OBSERVATION_PATH']!,
    ).writeAsString(
      jsonEncode(<String, Object?>{
        'iosVersion': ios.nextVersion,
        'iosCharacterLimit': ios.storeReleaseNotes.characterLimit,
        'changeType': ios.changes.single.type,
        'changeScope': ios.changes.single.scope,
        'changeDescription': ios.changes.single.description,
        'changeBody': ios.changes.single.body,
        'androidVersion': android.nextVersion,
        'androidCharacterLimit': android.storeReleaseNotes.characterLimit,
        'androidDescription': android.changes.single.description,
        'configuredSecret': context.secrets['TEST_API_KEY'],
        'hasUnlistedSecret': context.secrets.containsKey('UNLISTED_SECRET'),
      }),
      flush: true,
    );
    ios.storeReleaseNotes.write(
      locale: 'pt-BR',
      message: 'Novidades locais.',
    );
    android.storeReleaseNotes.write(
      locale: 'pt-BR',
      message: 'Novidades locais no Android.',
    );
  }
}

Future<void> main() => runSmfHook(WriteStoreReleaseNotesHook());
