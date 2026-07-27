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

const String _topLevelUsage = '''
SMF release automation

Usage: smf <command> [options]

Commands:
  init         Initialize SMF in a Flutter repository.
  validate     Validate repository configuration.
  plan         Preview the next release.
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

Future<int> runSmfExecutable(List<String> arguments, {ExecutableIo? io}) async {
  final resolvedIo = io ?? ExecutableIo.system();
  if (arguments.isEmpty ||
      arguments.first == '--help' ||
      arguments.first == '-h') {
    resolvedIo.writeOutput(_topLevelUsage);
    return arguments.isEmpty ? 64 : 0;
  }
  final command = arguments.first;
  final options = arguments.sublist(1);
  return switch (command) {
    'init' => runInitExecutable(options, io: resolvedIo),
    'validate' => runValidateExecutable(options, io: resolvedIo),
    'plan' => runPlanExecutable(options, io: resolvedIo),
    'open-pr' => runOpenPrExecutable(options, io: resolvedIo),
    'release' => runOpenPrExecutable(options, name: 'release', io: resolvedIo),
    'candidate' => runCandidateExecutable(
      options,
      name: 'candidate',
      io: resolvedIo,
    ),
    'testflight' => runCandidateExecutable(
      options,
      forcedPlatform: Platform.ios,
      io: resolvedIo,
    ),
    'internal-testing' => runCandidateExecutable(
      options,
      name: 'internal_testing',
      forcedPlatform: Platform.android,
      io: resolvedIo,
    ),
    'promote' => runPromoteExecutable(options, io: resolvedIo),
    'app-store' => runPromoteExecutable(
      options,
      name: 'app_store',
      forcedPlatform: Platform.ios,
      io: resolvedIo,
    ),
    'google-play' => runPromoteExecutable(
      options,
      name: 'google_play',
      forcedPlatform: Platform.android,
      io: resolvedIo,
    ),
    'action' => runActionExecutable(options, io: resolvedIo),
    _ => _unknownCommand(command, resolvedIo),
  };
}

int _unknownCommand(String command, ExecutableIo io) {
  io.writeError('smf: unknown command "$command".');
  io.writeError(_topLevelUsage);
  return 64;
}

ArgParser _options() =>
    ArgParser()..addFlag('help', abbr: 'h', negatable: false);

String _usage(String name, String description, ArgParser parser) =>
    '''
Usage: smf ${name.replaceAll('_', '-')} [options]

$description

Options:
${parser.usage}

Secrets are accepted through SMF_* environment variables or the
documented *_PATH variables, never as command-line values.
''';

Future<int> _runExecutable({
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

String _workingDirectory(ExecutableIo io, [String? override]) => p.normalize(
  p.absolute(
    override?.trim().isNotEmpty ?? false ? override! : io.workingDirectory,
  ),
);

String? _smfPath(ArgResults arguments) {
  final value = arguments.option('smf-path')?.trim();
  return value == null || value.isEmpty ? null : value;
}

String _initAppRoot(ArgResults arguments, ExecutableIo io) {
  final workingDirectory = _workingDirectory(io);
  final smfPath = _smfPath(arguments);
  if (smfPath == null) return workingDirectory;
  final directory = p.normalize(p.absolute(workingDirectory, smfPath));
  invariant(
    p.basename(directory) == smfDirectoryName &&
        (p.equals(directory, workingDirectory) ||
            p.isWithin(workingDirectory, directory)),
    '--smf-path must point to a forward directory named "smf".',
    'INVALID_SMF_PATH',
  );
  return p.dirname(directory);
}

String? _environmentValue(Map<String, String> environment, List<String> names) {
  for (final name in names) {
    final value = environment[name]?.trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

Future<String?> _token(ArgResults arguments, ExecutableIo io) async {
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
  invariant(
    value.isNotEmpty,
    'The GitHub token file is empty.',
    'INVALID_CREDENTIAL',
  );
  return value;
}

String? _repository(ArgResults arguments, ExecutableIo io) =>
    arguments.option('repository')?.trim() ??
    _environmentValue(io.environment, const <String>['GITHUB_REPOSITORY']);

Future<GitHubContext?> _optionalGitHub(
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
  if (repository == null ||
      !RegExp(r'^[^/\s]+/[^/\s]+$').hasMatch(repository)) {
    throw const SmfError(
      'A GitHub repository in owner/name form is required.',
      'GITHUB_REPOSITORY_REQUIRED',
    );
  }
  final parts = repository.split('/');
  return GitHubContext(owner: parts[0], repo: parts[1], token: token);
}

Future<GitHubContext> _requiredGitHub(
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

ArgParser _githubOptions() => _options()
  ..addOption('smf-path')
  ..addOption('repository')
  ..addOption('github-token-file');

Future<int> runInitExecutable(List<String> arguments, {ExecutableIo? io}) {
  final parser = _options()
    ..addOption('smf-path')
    ..addOption('current-version')
    ..addOption('bundle-id')
    ..addOption('package-name')
    ..addFlag('force', negatable: false)
    ..addFlag('workflow-only', negatable: false);
  return _runExecutable(
    name: 'init',
    description: 'Create smf/config.yaml and the starter GitHub workflow.',
    arguments: arguments,
    parser: parser,
    io: io,
    operation: (arguments, io) async {
      final appRoot = _initAppRoot(arguments, io);
      final workflowOnly = arguments.flag('workflow-only');
      await initialize(
        InitOptions(
          appRoot: appRoot,
          currentVersion: arguments.option('current-version'),
          bundleId: arguments.option('bundle-id'),
          packageName: arguments.option('package-name'),
          force: arguments.flag('force'),
          workflowOnly: workflowOnly,
        ),
      );
      return <String, Object?>{
        'smfPath': smfPathsForApp(appRoot).directory,
        if (workflowOnly) 'workflowUpdated': true else 'initialized': true,
      };
    },
  );
}

Future<int> runValidateExecutable(List<String> arguments, {ExecutableIo? io}) {
  final parser = _options()..addOption('smf-path');
  return _runExecutable(
    name: 'validate',
    description: 'Validate configuration and repository safety invariants.',
    arguments: arguments,
    parser: parser,
    io: io,
    operation: (arguments, io) async {
      final paths = resolveSmfPaths(
        _workingDirectory(io),
        smfPath: _smfPath(arguments),
      );
      await validateRepository(paths.directory);
      return const <String, Object?>{'valid': true};
    },
  );
}

Future<int> runPlanExecutable(List<String> arguments, {ExecutableIo? io}) {
  final parser = _options()..addOption('smf-path');
  return _runExecutable(
    name: 'plan',
    description: 'Print every enabled platform plan without changing files.',
    arguments: arguments,
    parser: parser,
    io: io,
    operation: (arguments, io) async {
      final paths = resolveSmfPaths(
        _workingDirectory(io),
        smfPath: _smfPath(arguments),
      );
      final config = await loadConfig(paths.directory);
      final manifest = await loadManifest(paths.directory);
      return <Object?>[
        for (final platform in config.enabledPlatforms)
          if (await createReleasePlan(
                paths.repositoryRoot,
                manifest,
                platform,
              )
              case final plan?)
            plan.toJson(),
      ];
    },
  );
}

Future<int> runOpenPrExecutable(
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
    operation: (arguments, io) async => (await planGitHubRelease(
      workingDirectory: _workingDirectory(io),
      smfPath: _smfPath(arguments),
      github: await _requiredGitHub(arguments, io),
    )).toJson(),
  );
}

Future<int> runCandidateExecutable(
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
      return switch (platform) {
        Platform.ios => (await apple.createIosCandidate(
          apple.CandidateOptions(
            workingDirectory: workingDirectory,
            smfPath: smfPath,
            appleCredentials: await apple.appleCredentialsFromEnvironment(
              io.environment,
            ),
            signingCredentials: await apple.signingCredentialsFromEnvironment(
              io.environment,
            ),
            github: github,
            commitReceipt: commitReceipt,
          ),
        )).toJson(),
        Platform.android => (await android.createAndroidCandidate(
          android.AndroidCandidateOptions(
            workingDirectory: workingDirectory,
            smfPath: smfPath,
            googlePlayCredentials: await android
                .googlePlayCredentialsFromEnvironment(
                  io.environment,
                ),
            signingCredentials: await android
                .androidSigningCredentialsFromEnvironment(
                  io.environment,
                ),
            github: github,
            commitReceipt: commitReceipt,
          ),
        )).toJson(),
      };
    },
  );
}

Future<int> runPromoteExecutable(
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
      return switch (platform) {
        Platform.ios => (await apple.promoteIosRelease(
          apple.PromotionOptions(
            workingDirectory: workingDirectory,
            smfPath: smfPath,
            appleCredentials: await apple.appleCredentialsFromEnvironment(
              io.environment,
            ),
            github: github,
          ),
        )).toJson(),
        Platform.android => (await android.promoteAndroidRelease(
          android.AndroidPromotionOptions(
            workingDirectory: workingDirectory,
            smfPath: smfPath,
            googlePlayCredentials: await android
                .googlePlayCredentialsFromEnvironment(
                  io.environment,
                ),
            github: github,
          ),
        )).toJson(),
      };
    },
  );
}

Future<Platform> _selectedPlatform(
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
  final paths = resolveSmfPaths(workingDirectory, smfPath: smfPath);
  final enabled = (await loadConfig(paths.directory)).enabledPlatforms;
  if (enabled.length == 1) return enabled.single;
  throw const SmfError(
    'Select --platform ios or --platform android when multiple platforms are '
        'enabled.',
    'PLATFORM_REQUIRED',
  );
}

Future<int> runActionExecutable(List<String> arguments, {ExecutableIo? io}) {
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
      switch (arguments.option('phase')) {
        case 'pull-request':
          return (await planGitHubRelease(
            workingDirectory: workingDirectory,
            smfPath: smfPath,
            github: await _requiredGitHub(arguments, io),
          )).toJson();
        case 'release-candidate':
          final github = await _requiredGitHub(arguments, io);
          final platform = arguments.option('platform');
          invariant(
            platform != null,
            '--platform is required for release-candidate.',
            'PLATFORM_REQUIRED',
          );
          return switch (Platform.parse(platform!)) {
            Platform.ios => (await apple.createIosCandidate(
              apple.CandidateOptions(
                workingDirectory: workingDirectory,
                smfPath: smfPath,
                appleCredentials: await apple.appleCredentialsFromEnvironment(
                  io.environment,
                ),
                signingCredentials: await apple
                    .signingCredentialsFromEnvironment(
                      io.environment,
                    ),
                github: github,
              ),
            )).toJson(),
            Platform.android => (await android.createAndroidCandidate(
              android.AndroidCandidateOptions(
                workingDirectory: workingDirectory,
                smfPath: smfPath,
                googlePlayCredentials: await android
                    .googlePlayCredentialsFromEnvironment(
                      io.environment,
                    ),
                signingCredentials: await android
                    .androidSigningCredentialsFromEnvironment(
                      io.environment,
                    ),
                github: github,
              ),
            )).toJson(),
          };
        case 'ship':
          final platform = arguments.option('platform');
          invariant(
            platform != null,
            '--platform is required for ship.',
            'PLATFORM_REQUIRED',
          );
          final github = await _requiredGitHub(arguments, io);
          return switch (Platform.parse(platform!)) {
            Platform.ios => (await apple.promoteIosRelease(
              apple.PromotionOptions(
                workingDirectory: workingDirectory,
                smfPath: smfPath,
                appleCredentials: await apple.appleCredentialsFromEnvironment(
                  io.environment,
                ),
                github: github,
              ),
            )).toJson(),
            Platform.android => (await android.promoteAndroidRelease(
              android.AndroidPromotionOptions(
                workingDirectory: workingDirectory,
                smfPath: smfPath,
                googlePlayCredentials: await android
                    .googlePlayCredentialsFromEnvironment(
                      io.environment,
                    ),
                github: github,
              ),
            )).toJson(),
          };
      }
      throw const SmfError('Unsupported action phase.', 'INVALID_PHASE');
    },
  );
}
