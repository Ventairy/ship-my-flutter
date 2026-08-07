part of 'smf_hooks_sdk.dart';

/// One pending platform release supplied to an application's create-PR hook.
final class PlatformRelease {
  PlatformRelease._({
    required this.nextVersion,
    required this.changes,
    required this.storeReleaseNotes,
  });

  factory PlatformRelease._fromJson(
    Map<String, Object?> json, {
    required HookReleasePlatform platform,
    required File storeReleaseNotesFile,
  }) => PlatformRelease._(
    nextVersion: _HookModelDecoder.string(
      json,
      SmfHookProtocol.nextVersionField,
    ),
    changes: List<ConventionalChange>.unmodifiable(
      _HookModelDecoder.list(json, SmfHookProtocol.changesField).map((value) {
        final change = _HookModelDecoder.object(value, 'change');
        return ConventionalChange._(
          type: _HookModelDecoder.string(
            change,
            SmfHookProtocol.changeTypeField,
          ),
          scope: _HookModelDecoder.optionalString(
            change,
            SmfHookProtocol.changeScopeField,
          ),
          description: _HookModelDecoder.string(
            change,
            SmfHookProtocol.changeDescriptionField,
          ),
          body: _HookModelDecoder.optionalString(
            change,
            SmfHookProtocol.changeBodyField,
          ),
        );
      }),
    ),
    storeReleaseNotes: StoreReleaseNotes._(
      file: storeReleaseNotesFile,
      platform: platform,
      version: _HookModelDecoder.string(
        json,
        SmfHookProtocol.nextVersionField,
      ),
    ),
  );

  /// Planned platform marketing version.
  final String nextVersion;

  /// Changes included in the platform release.
  final List<ConventionalChange> changes;

  /// Writer for this version's localized store release notes.
  final StoreReleaseNotes storeReleaseNotes;
}
