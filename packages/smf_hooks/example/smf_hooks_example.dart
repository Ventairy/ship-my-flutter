import 'package:smf_hooks/smf_hooks.dart';

final class WriteStoreReleaseNotes extends SmfHook {
  @override
  Future<void> run(SmfBeforeCreatePrContext context) async {
    final ios = context.release.ios;
    if (ios != null) {
      ios.storeReleaseNotes.write(
        locale: 'en-US',
        message: ios.changes.map((change) => '- ${change.description}').join('\n'),
      );
    }

    final android = context.release.android;
    if (android != null) {
      android.storeReleaseNotes.write(
        locale: 'en-US',
        message: android.changes.map((change) => '- ${change.description}').join('\n'),
      );
    }
  }
}

Future<void> main() => WriteStoreReleaseNotes().execute();
