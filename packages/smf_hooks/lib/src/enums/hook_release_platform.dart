import 'package:smf_hooks/smf_hooks_protocol.dart';

/// Store platform available to an SMF hook.
enum HookReleasePlatform {
  /// Apple's iOS platform.
  ios(
    characterLimit: SmfHookProtocol.iosStoreReleaseNotesCharacterLimit,
  ),

  /// Google's Android platform.
  android(
    characterLimit: SmfHookProtocol.androidStoreReleaseNotesCharacterLimit,
  );

  const HookReleasePlatform({required this.characterLimit});

  /// Maximum store release-note length for this platform.
  final int characterLimit;
}
