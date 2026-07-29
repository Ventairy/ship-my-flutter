part of 'smf_hooks_sdk.dart';

final class _SmfHookRunner {
  const _SmfHookRunner(this._environment);

  final Map<String, String> _environment;

  Future<void> execute(SmfHook hook) async {
    final contextPath = _requiredEnvironment(
      SmfHookProtocol.contextPathEnvironment,
    );
    final resultPath = _requiredEnvironment(
      SmfHookProtocol.resultPathEnvironment,
    );
    final context = await _readContext(contextPath);
    await hook.run(context);
    await _writeJson(resultPath, <String, Object?>{
      SmfHookProtocol.schemaVersionField: SmfHookProtocol.schemaVersion,
    });
  }

  Future<SmfHookContext> _readContext(String path) async {
    try {
      final value = await _readJson(path);
      final json = _object(value, 'hook context');
      final schemaVersion = json[SmfHookProtocol.schemaVersionField];
      if (schemaVersion != SmfHookProtocol.schemaVersion) {
        throw FormatException(
          'Unsupported SMF hook schema version "$schemaVersion".',
        );
      }
      final phase = SmfHookProtocolPhase.parse(
        _string(json, SmfHookProtocol.phaseField),
      );
      return switch (phase) {
        SmfHookProtocolPhase.beforeCreatePr => SmfBeforeCreatePrContext._(
          release: PlannedReleases._(
            ios: json[SmfHookProtocol.iosReleaseField] == null
                ? null
                : PlatformRelease._fromJson(
                    _object(
                      json[SmfHookProtocol.iosReleaseField],
                      SmfHookProtocol.iosReleaseField,
                    ),
                    platform: HookReleasePlatform.ios,
                    storeReleaseNotesFile: File(
                      _string(
                        json,
                        SmfHookProtocol.storeReleaseNotesFileField,
                      ),
                    ),
                  ),
            android: json[SmfHookProtocol.androidReleaseField] == null
                ? null
                : PlatformRelease._fromJson(
                    _object(
                      json[SmfHookProtocol.androidReleaseField],
                      SmfHookProtocol.androidReleaseField,
                    ),
                    platform: HookReleasePlatform.android,
                    storeReleaseNotesFile: File(
                      _string(
                        json,
                        SmfHookProtocol.storeReleaseNotesFileField,
                      ),
                    ),
                  ),
          ),
        ),
        SmfHookProtocolPhase.beforeBuild => SmfBeforeBuildContext._(
          repositoryRoot: Directory(
            _string(json, SmfHookProtocol.repositoryRootField),
          ),
        ),
      };
    } on Object catch (error) {
      throw FormatException('The SMF hook context is invalid: $error');
    }
  }

  String _requiredEnvironment(String name) {
    final value = _environment[name]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('$name is required when running an SMF hook.');
    }
    return value;
  }

  Future<Object?> _readJson(String path) async => jsonDecode(await File(path).readAsString());

  Future<void> _writeJson(String path, Object? value) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(value)}\n',
    );
  }

  Map<String, Object?> _object(Object? value, String name) {
    if (value is! Map<Object?, Object?>) {
      throw FormatException('$name must be an object.');
    }
    return <String, Object?>{
      for (final entry in value.entries) entry.key.toString(): entry.value,
    };
  }

  String _string(Map<String, Object?> json, String name) {
    final value = json[name];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$name must be a non-empty string.');
    }
    return value;
  }
}
