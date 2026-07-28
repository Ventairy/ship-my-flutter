/// Internal wire contract shared by the SMF engine and hook runtime.
///
/// Application hooks should import `package:smf_hooks/smf_hooks.dart` instead.
library;

/// Hook phase encoded by the engine.
enum SmfHookProtocolPhase {
  /// Runs before creating or updating the release pull request.
  beforeCreatePr('before_create_pr'),

  /// Runs before fingerprinting and building one store candidate.
  beforeBuild('before_build');

  const SmfHookProtocolPhase(this.value);

  /// Stable wire value.
  final String value;

  /// Parses one exact wire value.
  static SmfHookProtocolPhase parse(String value) {
    for (final phase in values) {
      if (phase.value == value) return phase;
    }
    throw FormatException('Unsupported SMF hook phase "$value".');
  }
}

/// Single owner for hook environment names and JSON fields.
abstract final class SmfHookProtocol {
  /// Current wire schema.
  static const int schemaVersion = 1;

  /// Apple store-release-note character limit.
  static const int iosStoreReleaseNotesCharacterLimit = 4000;

  /// Google Play store-release-note character limit.
  static const int androidStoreReleaseNotesCharacterLimit = 500;

  /// Environment variable containing the context JSON path.
  static const String contextPathEnvironment = 'SMF_HOOK_CONTEXT_PATH';

  /// Environment variable containing the completion JSON path.
  static const String resultPathEnvironment = 'SMF_HOOK_RESULT_PATH';

  /// Schema-version JSON field.
  static const String schemaVersionField = 'schemaVersion';

  /// Hook-phase JSON field.
  static const String phaseField = 'phase';

  /// Store-release-notes file JSON field.
  static const String storeReleaseNotesFileField = 'storeReleaseNotesFile';

  /// Nullable iOS release JSON field.
  static const String iosReleaseField = 'iosRelease';

  /// Nullable Android release JSON field.
  static const String androidReleaseField = 'androidRelease';

  /// Repository-root JSON field.
  static const String repositoryRootField = 'repositoryRoot';

  /// Planned next-version JSON field.
  static const String nextVersionField = 'nextVersion';

  /// Planned changes JSON field.
  static const String changesField = 'changes';

  /// Conventional-change type JSON field.
  static const String changeTypeField = 'type';

  /// Conventional-change scope JSON field.
  static const String changeScopeField = 'scope';

  /// Conventional-change description JSON field.
  static const String changeDescriptionField = 'description';

  /// Conventional-change body JSON field.
  static const String changeBodyField = 'body';
}
