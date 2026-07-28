import 'dart:convert';
import 'dart:io' as dart_io;

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:smf_android/smf_android.dart' as android;
import 'package:smf_apple/smf_apple.dart' as apple;
import 'package:smf_engine/smf_engine.dart';

final class ExecutableIo {
  const ExecutableIo({
    required this.environment,
    required this.workingDirectory,
    required this.writeOutput,
    required this.writeError,
  });

  factory ExecutableIo.system() => ExecutableIo(
    environment: dart_io.Platform.environment,
    workingDirectory: dart_io.Directory.current.path,
    writeOutput: dart_io.stdout.writeln,
    writeError: dart_io.stderr.writeln,
  );

  final Map<String, String> environment;
  final String workingDirectory;
  final void Function(Object? value) writeOutput;
  final void Function(Object? value) writeError;
}

/// Dispatches SMF command-line operations.
final class SmfExecutable {
  const SmfExecutable._();

  static const String _topLevelUsage = '''
SMF release automation

Usage: smf <command> [options]

Commands:
  init         Initialize SMF in a Flutter repository.
  migrate      Migrate SMF files to the installed version.
  validate     Validate repository configuration.
  open-pr      Open or update a release pull request.
  release      Alias for open-pr.
  candidate    Create a tested store candidate for one platform.
  testflight   Create an iOS TestFlight candidate.
  internal-testing
               Create an Android Google Play internal-testing candidate.
  promote      Promote one exact tested platform candidate.
  app-store    Promote the iOS candidate.
  google-play  Promote the Android candidate.
''';

  /// Runs the top-level SMF command.
  static Future<int> run(
    List<String> arguments, {
    ExecutableIo? io,
  }) async {
    final resolvedIo = io ?? ExecutableIo.system();
    if (arguments.isEmpty || arguments.first == '--help' || arguments.first == '-h') {
      resolvedIo.writeOutput(_topLevelUsage);
      return arguments.isEmpty ? 64 : 0;
    }
    final command = arguments.first;
    final options = arguments.sublist(1);
    return switch (command) {
      'init' => runInit(options, io: resolvedIo),
      'migrate' => runMigrate(options, io: resolvedIo),
      'validate' => runValidate(options, io: resolvedIo),
      'open-pr' => runOpenPullRequest(options, io: resolvedIo),
      'release' => runOpenPullRequest(options, name: 'release', io: resolvedIo),
      'candidate' => runCandidate(
        options,
        name: 'candidate',
        io: resolvedIo,
      ),
      'testflight' => runCandidate(
        options,
        forcedPlatform: Platform.ios,
        io: resolvedIo,
      ),
      'internal-testing' => runCandidate(
        options,
        name: 'internal_testing',
        forcedPlatform: Platform.android,
        io: resolvedIo,
      ),
      'promote' => runPromote(options, io: resolvedIo),
      'app-store' => runPromote(
        options,
        name: 'app_store',
        forcedPlatform: Platform.ios,
        io: resolvedIo,
      ),
      'google-play' => runPromote(
        options,
        name: 'google_play',
        forcedPlatform: Platform.android,
        io: resolvedIo,
      ),
      'action' => runAction(options, io: resolvedIo),
      _ => _unknownCommand(command, resolvedIo),
    };
  }

  static int _unknownCommand(String command, ExecutableIo io) {
    io.writeError('smf: unknown command "$command".');
    io.writeError(_topLevelUsage);
    return 64;
  }

  static ArgParser _options() => ArgParser()..addFlag('help', abbr: 'h', negatable: false);

  static String _usage(String name, String description, ArgParser parser) =>
      '''
Usage: smf ${name.replaceAll('_', '-')} [options]

$description

Options:
${parser.usage}

Secrets are accepted through SMF_* environment variables or the
documented *_PATH variables, never as command-line values.
''';

  static Future<int> _runExecutable({
    required String name,
    required String description,
    required List<String> arguments,
    required ArgParser parser,
    required Future<Object?> Function(ArgResults, ExecutableIo) operation,
    ExecutableIo? io,
  }) async {
    final resolvedIo = io ?? ExecutableIo.system();
    try {
      final results = parser.parse(arguments);
      if (results.flag('help')) {
        resolvedIo.writeOutput(_usage(name, description, parser));
        return 0;
      }
      final value = await operation(results, resolvedIo);
      resolvedIo.writeOutput(const JsonEncoder.withIndent('  ').convert(value));
      return 0;
    } on FormatException catch (error) {
      resolvedIo.writeError('smf ${name.replaceAll('_', '-')}: ${error.message}');
      resolvedIo.writeError(_usage(name, description, parser));
      return 64;
    } on SmfError catch (error) {
      resolvedIo.writeError(
        'smf ${name.replaceAll('_', '-')} '
        '[${error.code}]: ${error.message}',
      );
      return 1;
    } on GitHubApiException catch (error) {
      resolvedIo.writeError(
        'smf ${name.replaceAll('_', '-')} [GITHUB_API]: '
        'GitHub ${error.method} ${error.path} '
        'failed (${error.statusCode}).',
      );
      return 1;
    } on dart_io.FileSystemException catch (error) {
      resolvedIo.writeError(
        'smf ${name.replaceAll('_', '-')} [FILESYSTEM]: ${error.message}',
      );
      return 1;
    }
  }

  static String _workingDirectory(ExecutableIo io, [String? override]) => p.normalize(
    p.absolute(
      override?.trim().isNotEmpty ?? false ? override! : io.workingDirectory,
    ),
  );

  static String? _smfPath(ArgResults arguments) {
    final value = arguments.option('smf-path')?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static String _initAppRoot(ArgResults arguments, ExecutableIo io) {
    final workingDirectory = _workingDirectory(io);
    final appPath = arguments.option('app-path')?.trim();
    if (appPath == null || appPath.isEmpty) return workingDirectory;
    final directory = p.normalize(p.absolute(workingDirectory, appPath));
    SmfError.check(
      p.equals(directory, workingDirectory) || p.isWithin(workingDirectory, directory),
      '--app-path must point to the current directory or a directory below it.',
      'INVALID_APP_PATH',
    );
    if (dart_io.Directory(directory).existsSync()) {
      final realWorkingDirectory = dart_io.Directory(
        workingDirectory,
      ).resolveSymbolicLinksSync();
      final realDirectory = dart_io.Directory(
        directory,
      ).resolveSymbolicLinksSync();
      SmfError.check(
        p.equals(realDirectory, realWorkingDirectory) || p.isWithin(realWorkingDirectory, realDirectory),
        '--app-path must not escape the current directory through a symbolic '
            'link.',
        'INVALID_APP_PATH',
      );
    }
    return directory;
  }

  static String? _environmentValue(Map<String, String> environment, List<String> names) {
    for (final name in names) {
      final value = environment[name]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static Future<String?> _token(ArgResults arguments, ExecutableIo io) async {
    final path = arguments.option('github-token-file')?.trim();
    final environmentToken = _environmentValue(io.environment, const <String>[
      'SMF_GITHUB_TOKEN',
      'GITHUB_TOKEN',
      'INPUT_GITHUB_TOKEN',
    ]);
    if (path != null && path.isNotEmpty && environmentToken != null) {
      throw const SmfError(
        'Set only one GitHub token source: --github-token-file or an environment '
            'variable.',
        'CONFLICTING_CREDENTIAL',
      );
    }
    if (path == null || path.isEmpty) return environmentToken;
    final value = (await dart_io.File(path).readAsString()).trim();
    SmfError.check(
      value.isNotEmpty,
      'The GitHub token file is empty.',
      'INVALID_CREDENTIAL',
    );
    return value;
  }

  static String? _repository(ArgResults arguments, ExecutableIo io) =>
      arguments.option('repository')?.trim() ?? _environmentValue(io.environment, const <String>['GITHUB_REPOSITORY']);

  static Future<GitHubContext?> _optionalGitHub(
    ArgResults arguments,
    ExecutableIo io,
  ) async {
    final token = await _token(arguments, io);
    final repository = _repository(arguments, io);
    if (token == null && repository == null) return null;
    if (token == null) {
      throw const SmfError(
        'A GitHub token is required. Set SMF_GITHUB_TOKEN or GITHUB_TOKEN.',
        'GITHUB_TOKEN_REQUIRED',
      );
    }
    if (repository == null || !RegExp(r'^[^/\s]+/[^/\s]+$').hasMatch(repository)) {
      throw const SmfError(
        'A GitHub repository in owner/name form is required.',
        'GITHUB_REPOSITORY_REQUIRED',
      );
    }
    final parts = repository.split('/');
    return GitHubContext(owner: parts[0], repo: parts[1], token: token);
  }

  static Future<GitHubContext> _requiredGitHub(
    ArgResults arguments,
    ExecutableIo io,
  ) async {
    final context = await _optionalGitHub(arguments, io);
    if (context == null) {
      throw const SmfError(
        'GitHub credentials are required for this operation.',
        'GITHUB_CREDENTIALS_REQUIRED',
      );
    }
    return context;
  }

  static ArgParser _githubOptions() => _options()
    ..addOption('smf-path')
    ..addOption('repository')
    ..addOption('github-token-file');

  static Future<int> runInit(List<String> arguments, {ExecutableIo? io}) {
    final parser = _options()
      ..addOption('app-path')
      ..addOption('app-id')
      ..addOption('version')
      ..addOption('ios-version')
      ..addOption('android-version')
      ..addOption('ios-bundle-id')
      ..addOption('android-package-name')
      ..addFlag('force', negatable: false)
      ..addFlag('github-actions', negatable: false);
    return _runExecutable(
      name: 'init',
      description: 'Create smf/config.yaml and the starter GitHub workflow.',
      arguments: arguments,
      parser: parser,
      io: io,
      operation: (arguments, io) async {
        final appRoot = _initAppRoot(arguments, io);
        final githubActionsOnly = arguments.flag('github-actions');
        final iosVersion = arguments.option('ios-version');
        final androidVersion = arguments.option('android-version');
        await RepositoryInitializer.initialize(
          InitOptions(
            appRoot: appRoot,
            appId: arguments.option('app-id'),
            version: arguments.option('version'),
            platformVersions: <Platform, String>{
              Platform.ios: ?iosVersion,
              Platform.android: ?androidVersion,
            },
            platformVersionDetectors: <Platform, Future<String?> Function(String appRoot)>{
              Platform.ios: apple.AppleProject.detectVersion,
              Platform.android: android.AndroidProject.detectVersion,
            },
            iosBundleId: arguments.option('ios-bundle-id'),
            androidPackageName: arguments.option('android-package-name'),
            force: arguments.flag('force'),
            githubActionsOnly: githubActionsOnly,
          ),
        );
        final config = await SmfState.config(SmfPaths.forApp(appRoot).directory);
        return <String, Object?>{
          'appId': config.appId,
          'smfPath': SmfPaths.forApp(appRoot).directory,
          if (githubActionsOnly) 'githubActionsCreated': true else 'initialized': true,
        };
      },
    );
  }

  static Future<int> runMigrate(List<String> arguments, {ExecutableIo? io}) {
    final parser = _options()
      ..addOption('smf-path')
      ..addOption('app-id')
      ..addFlag('config', negatable: false)
      ..addFlag('github-actions', negatable: false)
      ..addFlag('registry', negatable: false);
    return _runExecutable(
      name: 'migrate',
      description: 'Migrate selected SMF files to the installed version.',
      arguments: arguments,
      parser: parser,
      io: io,
      operation: (arguments, io) async => (await SmfMigration.migrate(
        MigrationOptions(
          workingDirectory: _workingDirectory(io),
          smfPath: _smfPath(arguments),
          appId: arguments.option('app-id'),
          config: arguments.flag('config'),
          githubActions: arguments.flag('github-actions'),
          registry: arguments.flag('registry'),
        ),
      )).toJson(),
    );
  }

  static Future<int> runValidate(List<String> arguments, {ExecutableIo? io}) {
    final parser = _options()..addOption('smf-path');
    return _runExecutable(
      name: 'validate',
      description: 'Validate configuration and repository safety invariants.',
      arguments: arguments,
      parser: parser,
      io: io,
      operation: (arguments, io) async {
        final paths = SmfPaths.resolve(
          _workingDirectory(io),
          smfPath: _smfPath(arguments),
        );
        await RepositoryValidator.validate(paths.directory);
        return const <String, Object?>{'valid': true};
      },
    );
  }

  static Future<int> runOpenPullRequest(
    List<String> arguments, {
    String name = 'open_pr',
    ExecutableIo? io,
  }) {
    final parser = _githubOptions();
    return _runExecutable(
      name: name,
      description: 'Open or update the shared platform release pull request.',
      arguments: arguments,
      parser: parser,
      io: io,
      operation: (arguments, io) async => (await const ReleaseOrchestrator().plan(
        workingDirectory: _workingDirectory(io),
        smfPath: _smfPath(arguments),
        github: await _requiredGitHub(arguments, io),
      )).toJson(),
    );
  }

  static Future<int> runCandidate(
    List<String> arguments, {
    String name = 'testflight',
    Platform? forcedPlatform,
    ExecutableIo? io,
  }) {
    final parser = _githubOptions()
      ..addOption(
        'platform',
        allowed: Platform.values.map((platform) => platform.value),
        hide: forcedPlatform != null,
      )
      ..addFlag('commit-receipt', defaultsTo: true);
    return _runExecutable(
      name: name,
      description: 'Build, sign, upload, and record one store candidate.',
      arguments: arguments,
      parser: parser,
      io: io,
      operation: (arguments, io) async {
        final workingDirectory = _workingDirectory(io);
        final smfPath = _smfPath(arguments);
        final platform = await _selectedPlatform(
          arguments,
          workingDirectory: workingDirectory,
          smfPath: smfPath,
          forcedPlatform: forcedPlatform,
        );
        final github = await _optionalGitHub(arguments, io);
        final commitReceipt = arguments.flag('commit-receipt');
        final appleCredentials = apple.AppleCredentialProvider(
          environment: io.environment,
        );
        final androidCredentials = android.AndroidCredentialProvider(
          environment: io.environment,
        );
        return switch (platform) {
          Platform.ios => (await apple.AppleCandidate.create(
            apple.AppleCandidateOptions(
              workingDirectory: workingDirectory,
              smfPath: smfPath,
              appleCredentials: await appleCredentials.appleCredentials(),
              signingCredentials: await appleCredentials.signingCredentials(),
              github: github,
              commitReceipt: commitReceipt,
            ),
          )).toJson(),
          Platform.android => (await android.AndroidCandidate.create(
            android.AndroidCandidateOptions(
              workingDirectory: workingDirectory,
              smfPath: smfPath,
              googlePlayCredentials: await androidCredentials.googlePlayCredentials(),
              signingCredentials: await androidCredentials.signingCredentials(),
              github: github,
              commitReceipt: commitReceipt,
            ),
          )).toJson(),
        };
      },
    );
  }

  static Future<int> runPromote(
    List<String> arguments, {
    String name = 'promote',
    Platform? forcedPlatform,
    ExecutableIo? io,
  }) {
    final parser = _githubOptions()
      ..addOption(
        'platform',
        allowed: Platform.values.map((platform) => platform.value),
        hide: forcedPlatform != null,
      );
    return _runExecutable(
      name: name,
      description: 'Promote the exact tested candidate after the release PR.',
      arguments: arguments,
      parser: parser,
      io: io,
      operation: (arguments, io) async {
        final workingDirectory = _workingDirectory(io);
        final smfPath = _smfPath(arguments);
        final platform = await _selectedPlatform(
          arguments,
          workingDirectory: workingDirectory,
          smfPath: smfPath,
          forcedPlatform: forcedPlatform,
        );
        final github = await _requiredGitHub(arguments, io);
        final appleCredentials = apple.AppleCredentialProvider(
          environment: io.environment,
        );
        final androidCredentials = android.AndroidCredentialProvider(
          environment: io.environment,
        );
        return switch (platform) {
          Platform.ios => (await apple.AppleRelease.promote(
            apple.ApplePromotionOptions(
              workingDirectory: workingDirectory,
              smfPath: smfPath,
              appleCredentials: await appleCredentials.appleCredentials(),
              github: github,
            ),
          )).toJson(),
          Platform.android => (await android.AndroidRelease.promote(
            android.AndroidPromotionOptions(
              workingDirectory: workingDirectory,
              smfPath: smfPath,
              googlePlayCredentials: await androidCredentials.googlePlayCredentials(),
              github: github,
            ),
          )).toJson(),
        };
      },
    );
  }

  static Future<Platform> _selectedPlatform(
    ArgResults arguments, {
    required String workingDirectory,
    required String? smfPath,
    Platform? forcedPlatform,
  }) async {
    final explicit = arguments.option('platform');
    if (forcedPlatform != null) {
      if (explicit != null && explicit != forcedPlatform.value) {
        throw SmfError(
          'This alias always selects ${forcedPlatform.value}.',
          'INVALID_PLATFORM',
        );
      }
      return forcedPlatform;
    }
    if (explicit != null) return Platform.parse(explicit);
    final paths = SmfPaths.resolve(workingDirectory, smfPath: smfPath);
    final enabled = (await SmfState.config(paths.directory)).enabledPlatforms;
    if (enabled.length == 1) return enabled.single;
    throw const SmfError(
      'Select --platform ios or --platform android when multiple platforms are '
          'enabled.',
      'PLATFORM_REQUIRED',
    );
  }

  static Future<int> runAction(List<String> arguments, {ExecutableIo? io}) {
    final parser = _githubOptions()
      ..addOption(
        'phase',
        allowed: const <String>['pull-request', 'release-candidate', 'ship'],
        mandatory: true,
      )
      ..addOption(
        'platform',
        allowed: Platform.values.map((platform) => platform.value),
      )
      ..addOption('working-directory', hide: true);
    return _runExecutable(
      name: 'action',
      description: 'Run the private smf-action machine adapter.',
      arguments: arguments,
      parser: parser,
      io: io,
      operation: (arguments, io) async {
        final workingDirectory = _workingDirectory(
          io,
          arguments.option('working-directory'),
        );
        final smfPath = _smfPath(arguments);
        final appleCredentials = apple.AppleCredentialProvider(
          environment: io.environment,
        );
        final androidCredentials = android.AndroidCredentialProvider(
          environment: io.environment,
        );
        switch (arguments.option('phase')) {
          case 'pull-request':
            return (await const ReleaseOrchestrator().plan(
              workingDirectory: workingDirectory,
              smfPath: smfPath,
              github: await _requiredGitHub(arguments, io),
            )).toJson();
          case 'release-candidate':
            final github = await _requiredGitHub(arguments, io);
            final platform = arguments.option('platform');
            SmfError.check(
              platform != null,
              '--platform is required for release-candidate.',
              'PLATFORM_REQUIRED',
            );
            return switch (Platform.parse(platform!)) {
              Platform.ios => (await apple.AppleCandidate.create(
                apple.AppleCandidateOptions(
                  workingDirectory: workingDirectory,
                  smfPath: smfPath,
                  appleCredentials: await appleCredentials.appleCredentials(),
                  signingCredentials: await appleCredentials.signingCredentials(),
                  github: github,
                ),
              )).toJson(),
              Platform.android => (await android.AndroidCandidate.create(
                android.AndroidCandidateOptions(
                  workingDirectory: workingDirectory,
                  smfPath: smfPath,
                  googlePlayCredentials: await androidCredentials.googlePlayCredentials(),
                  signingCredentials: await androidCredentials.signingCredentials(),
                  github: github,
                ),
              )).toJson(),
            };
          case 'ship':
            final platform = arguments.option('platform');
            SmfError.check(
              platform != null,
              '--platform is required for ship.',
              'PLATFORM_REQUIRED',
            );
            final github = await _requiredGitHub(arguments, io);
            return switch (Platform.parse(platform!)) {
              Platform.ios => (await apple.AppleRelease.promote(
                apple.ApplePromotionOptions(
                  workingDirectory: workingDirectory,
                  smfPath: smfPath,
                  appleCredentials: await appleCredentials.appleCredentials(),
                  github: github,
                ),
              )).toJson(),
              Platform.android => (await android.AndroidRelease.promote(
                android.AndroidPromotionOptions(
                  workingDirectory: workingDirectory,
                  smfPath: smfPath,
                  googlePlayCredentials: await androidCredentials.googlePlayCredentials(),
                  github: github,
                ),
              )).toJson(),
            };
        }
        throw const SmfError('Unsupported action phase.', 'INVALID_PHASE');
      },
    );
  }
}
