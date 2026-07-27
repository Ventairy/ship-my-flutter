import 'dart:convert';
import 'dart:io' as dart_io;

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:smf_apple/smf_apple.dart';
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

typedef _Operation =
    Future<Object?> Function(ArgResults arguments, ExecutableIo io);

const String _topLevelUsage = '''
SMF release automation

Usage: smf <command> [options]

Commands:
  init         Initialize SMF in a Flutter repository.
  validate     Validate repository configuration.
  plan         Preview the next release.
  open-pr      Open or update a release pull request.
  release      Alias for open-pr.
  candidate    Create an Apple release candidate.
  testflight   Alias for candidate.
  promote      Promote the tested Apple candidate.
  app-store    Alias for promote.
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
    'candidate' => runTestflightExecutable(
      options,
      name: 'candidate',
      io: resolvedIo,
    ),
    'testflight' => runTestflightExecutable(options, io: resolvedIo),
    'promote' => runPromoteExecutable(options, io: resolvedIo),
    'app-store' => runPromoteExecutable(
      options,
      name: 'app_store',
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
  required _Operation operation,
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
    description: 'Print the next iOS release plan without changing files.',
    arguments: arguments,
    parser: parser,
    io: io,
    operation: (arguments, io) async {
      final paths = resolveSmfPaths(
        _workingDirectory(io),
        smfPath: _smfPath(arguments),
      );
      return (await createReleasePlan(
        paths.repositoryRoot,
        await loadManifest(paths.directory),
        Platform.ios,
      ))?.toJson();
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
    description: 'Open or update the iOS release pull request.',
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

Future<int> runTestflightExecutable(
  List<String> arguments, {
  String name = 'testflight',
  ExecutableIo? io,
}) {
  final parser = _githubOptions()..addFlag('commit-receipt', defaultsTo: true);
  return _runExecutable(
    name: name,
    description: 'Build, sign, upload, and record the TestFlight candidate.',
    arguments: arguments,
    parser: parser,
    io: io,
    operation: (arguments, io) async => (await createIosCandidate(
      CandidateOptions(
        workingDirectory: _workingDirectory(io),
        smfPath: _smfPath(arguments),
        appleCredentials: await appleCredentialsFromEnvironment(io.environment),
        signingCredentials: await signingCredentialsFromEnvironment(
          io.environment,
        ),
        github: await _optionalGitHub(arguments, io),
        commitReceipt: arguments.flag('commit-receipt'),
      ),
    )).toJson(),
  );
}

Future<int> runPromoteExecutable(
  List<String> arguments, {
  String name = 'promote',
  ExecutableIo? io,
}) {
  final parser = _githubOptions();
  return _runExecutable(
    name: name,
    description: 'Promote the exact tested candidate after the release PR.',
    arguments: arguments,
    parser: parser,
    io: io,
    operation: (arguments, io) async => (await promoteIosRelease(
      PromotionOptions(
        workingDirectory: _workingDirectory(io),
        smfPath: _smfPath(arguments),
        appleCredentials: await appleCredentialsFromEnvironment(io.environment),
        github: await _requiredGitHub(arguments, io),
      ),
    )).toJson(),
  );
}

Future<int> runActionExecutable(List<String> arguments, {ExecutableIo? io}) {
  final parser = _githubOptions()
    ..addOption(
      'phase',
      allowed: const <String>['pull-request', 'release-candidate', 'ship'],
      mandatory: true,
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
          return (await createIosCandidate(
            CandidateOptions(
              workingDirectory: workingDirectory,
              smfPath: smfPath,
              appleCredentials: await appleCredentialsFromEnvironment(
                io.environment,
              ),
              signingCredentials: await signingCredentialsFromEnvironment(
                io.environment,
              ),
              github: github,
            ),
          )).toJson();
        case 'ship':
          return (await promoteIosRelease(
            PromotionOptions(
              workingDirectory: workingDirectory,
              smfPath: smfPath,
              appleCredentials: await appleCredentialsFromEnvironment(
                io.environment,
              ),
              github: await _requiredGitHub(arguments, io),
            ),
          )).toJson();
      }
      throw const SmfError('Unsupported action phase.', 'INVALID_PHASE');
    },
  );
}
