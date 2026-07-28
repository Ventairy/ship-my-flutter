import 'dart:convert';
import 'dart:io' as io;

import 'package:smf_hooks/smf_hooks_protocol.dart';
import 'package:smf_hooks/src/models.dart';

/// Typed non-secret context shared by every repository hook.
sealed class SmfHookContext {
  const SmfHookContext._();
}

/// Context supplied before SMF creates or updates a release pull request.
final class SmfBeforeCreatePrContext extends SmfHookContext {
  const SmfBeforeCreatePrContext._({required this.release}) : super._();

  /// Nullable iOS and Android plans entering the shared release pull request.
  final PlannedReleases release;
}

/// Context supplied before SMF fingerprints and builds a platform candidate.
final class SmfBeforeBuildContext extends SmfHookContext {
  const SmfBeforeBuildContext._({required io.Directory repositoryRoot}) : _repositoryRoot = repositoryRoot, super._();

  final io.Directory _repositoryRoot;

  /// Runs [command] through the platform shell.
  ///
  /// By default, the command runs from the hook process's current directory.
  /// Pass `root: true` to run it from the Git repository root.
  Future<void> runCommand(String command, {bool root = false}) async {
    final process = await io.Process.start(
      '/bin/sh',
      <String>['-c', command],
      workingDirectory: root ? _repositoryRoot.path : null,
      mode: io.ProcessStartMode.inheritStdio,
    );
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw io.ProcessException(
        '/bin/sh',
        <String>['-c', command],
        'Hook command failed.',
        exitCode,
      );
    }
  }
}

/// Base class for a typed repository hook.
///
/// Implement [run] in `smf/hooks/before_create_pr.dart` or
/// `smf/hooks/before_build.dart`, then call [runSmfHook] from `main`.
abstract class SmfHook {
  const SmfHook();

  /// Executes repository-owned preparation with a phase-specific context.
  Future<void> run(covariant SmfHookContext context);
}

/// Loads SMF's private protocol, runs [hook], and confirms completion.
///
/// Hook entrypoints omit [environment]. Tests can supply an isolated protocol
/// environment.
Future<void> runSmfHook(
  SmfHook hook, {
  Map<String, String>? environment,
}) => _SmfHookRunner(
  environment ?? io.Platform.environment,
).execute(hook);

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
          release: PlannedReleases(
            ios: json[SmfHookProtocol.iosReleaseField] == null
                ? null
                : PlatformRelease.fromJson(
                    _object(
                      json[SmfHookProtocol.iosReleaseField],
                      SmfHookProtocol.iosReleaseField,
                    ),
                    platform: HookReleasePlatform.ios,
                    storeReleaseNotesFile: io.File(
                      _string(
                        json,
                        SmfHookProtocol.storeReleaseNotesFileField,
                      ),
                    ),
                  ),
            android: json[SmfHookProtocol.androidReleaseField] == null
                ? null
                : PlatformRelease.fromJson(
                    _object(
                      json[SmfHookProtocol.androidReleaseField],
                      SmfHookProtocol.androidReleaseField,
                    ),
                    platform: HookReleasePlatform.android,
                    storeReleaseNotesFile: io.File(
                      _string(
                        json,
                        SmfHookProtocol.storeReleaseNotesFileField,
                      ),
                    ),
                  ),
          ),
        ),
        SmfHookProtocolPhase.beforeBuild => SmfBeforeBuildContext._(
          repositoryRoot: io.Directory(
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

  Future<Object?> _readJson(String path) async => jsonDecode(await io.File(path).readAsString());

  Future<void> _writeJson(String path, Object? value) async {
    final file = io.File(path);
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
