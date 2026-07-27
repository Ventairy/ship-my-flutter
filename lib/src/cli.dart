import 'dart:convert';
import 'dart:io' as dart_io;

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'apple/candidate.dart';
import 'apple/credentials.dart';
import 'apple/promote.dart';
import 'config.dart';
import 'error.dart';
import 'github_api.dart';
import 'init.dart';
import 'model.dart';
import 'orchestrator.dart';
import 'paths.dart';
import 'release_plan.dart';
import 'validate.dart';

const String smfVersion = '0.1.0'; // x-release-please-version

final class CliIo {
  const CliIo({
    required this.environment,
    required this.workingDirectory,
    required this.writeOutput,
    required this.writeError,
  });

  factory CliIo.system() => CliIo(
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

ArgParser _commandParser() =>
    ArgParser()..addFlag('help', abbr: 'h', negatable: false);

ArgParser _parser() {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addFlag('version', negatable: false);
  parser.addCommand(
    'init',
    _commandParser()
      ..addOption('smf-path')
      ..addOption('current-version')
      ..addOption('bundle-id')
      ..addFlag('force', negatable: false)
      ..addFlag('workflow-only', negatable: false),
  );
  parser.addCommand('validate', _commandParser()..addOption('smf-path'));
  parser.addCommand('plan', _commandParser()..addOption('smf-path'));
  for (final name in const <String>['open-pr', 'release']) {
    parser.addCommand(
      name,
      _commandParser()
        ..addOption('smf-path')
        ..addOption('repository')
        ..addOption('github-token-file'),
    );
  }
  for (final name in const <String>['candidate', 'testflight']) {
    parser.addCommand(
      name,
      _commandParser()
        ..addOption('smf-path')
        ..addOption('repository')
        ..addOption('github-token-file')
        ..addFlag('commit-receipt', defaultsTo: true),
    );
  }
  for (final name in const <String>['promote', 'app-store']) {
    parser.addCommand(
      name,
      _commandParser()
        ..addOption('smf-path')
        ..addOption('repository')
        ..addOption('github-token-file'),
    );
  }
  parser.addCommand(
    'action',
    _commandParser()
      ..addOption(
        'phase',
        allowed: const <String>['pull-request', 'release-candidate', 'ship'],
        mandatory: true,
      )
      ..addOption('working-directory', hide: true)
      ..addOption('smf-path')
      ..addOption('repository')
      ..addOption('github-token-file'),
  );
  return parser;
}

String _usage(ArgParser parser) =>
    '''
smf $smfVersion

Platform-scoped Flutter release PRs, TestFlight candidates, and App Store
delivery.

Usage: smf <command> [options]

Commands:
  init         Create smf/config.yaml and the starter GitHub workflow.
  validate     Validate configuration and repository safety invariants.
  plan         Print the next iOS release plan without changing files.
  open-pr      Open or update the iOS release PR.
  release      Alias for open-pr, suitable for custom automation.
  candidate    Build, sign, upload, and record the TestFlight candidate.
  testflight   Alias for candidate.
  promote      Promote the exact tested candidate after the release PR merges.
  app-store    Alias for promote.
  action       Machine protocol used by smf-action.

Global options:
${parser.usage}

Secrets are accepted through SMF_* environment variables or the
documented *_PATH variables, never as command-line values.
''';

String _workingDirectory(ArgResults command, CliIo io) => p.normalize(
  p.absolute(
    command.name == 'action'
        ? command.option('working-directory') ?? io.workingDirectory
        : io.workingDirectory,
  ),
);

String? _smfPath(ArgResults command) {
  final value = command.option('smf-path')?.trim();
  return value == null || value.isEmpty ? null : value;
}

String _initAppRoot(ArgResults command, CliIo io) {
  final workingDirectory = _workingDirectory(command, io);
  final smfPath = _smfPath(command);
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

Future<String?> _token(ArgResults command, CliIo io) async {
  final path = command.option('github-token-file')?.trim();
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

String? _repository(ArgResults command, CliIo io) =>
    command.option('repository')?.trim() ??
    _environmentValue(io.environment, const <String>['GITHUB_REPOSITORY']);

Future<GitHubContext?> _optionalGitHub(ArgResults command, CliIo io) async {
  final token = await _token(command, io);
  final repository = _repository(command, io);
  if (token == null && repository == null) return null;
  if (token == null) {
    throw const SmfError(
      'A GitHub token is required. Set SMF_GITHUB_TOKEN or '
          'GITHUB_TOKEN.',
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

Future<GitHubContext> _requiredGitHub(ArgResults command, CliIo io) async {
  final context = await _optionalGitHub(command, io);
  if (context == null) {
    throw const SmfError(
      'GitHub credentials are required for this command.',
      'GITHUB_CREDENTIALS_REQUIRED',
    );
  }
  return context;
}

void _printJson(CliIo io, Object? value) {
  io.writeOutput(const JsonEncoder.withIndent('  ').convert(value));
}

Future<Object?> _execute(ArgResults command, CliIo io) async {
  final workingDirectory = _workingDirectory(command, io);
  final smfPath = _smfPath(command);
  switch (command.name) {
    case 'init':
      final appRoot = _initAppRoot(command, io);
      final workflowOnly = command.flag('workflow-only');
      await initialize(
        InitOptions(
          appRoot: appRoot,
          currentVersion: command.option('current-version'),
          bundleId: command.option('bundle-id'),
          force: command.flag('force'),
          workflowOnly: workflowOnly,
        ),
      );
      final result = <String, Object?>{
        'smfPath': smfPathsForApp(appRoot).directory,
      };
      if (workflowOnly) {
        result['workflowUpdated'] = true;
      } else {
        result['initialized'] = true;
      }
      return result;
    case 'validate':
      final paths = resolveSmfPaths(workingDirectory, smfPath: smfPath);
      await validateRepository(paths.directory);
      return const <String, Object?>{'valid': true};
    case 'plan':
      final paths = resolveSmfPaths(workingDirectory, smfPath: smfPath);
      return (await createReleasePlan(
        paths.repositoryRoot,
        await loadManifest(paths.directory),
        Platform.ios,
      ))?.toJson();
    case 'open-pr':
    case 'release':
      return (await planGitHubRelease(
        workingDirectory: workingDirectory,
        smfPath: smfPath,
        github: await _requiredGitHub(command, io),
      )).toJson();
    case 'candidate':
    case 'testflight':
      final github = await _optionalGitHub(command, io);
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
          commitReceipt: command.flag('commit-receipt'),
        ),
      )).toJson();
    case 'promote':
    case 'app-store':
      return (await promoteIosRelease(
        PromotionOptions(
          workingDirectory: workingDirectory,
          smfPath: smfPath,
          appleCredentials: await appleCredentialsFromEnvironment(
            io.environment,
          ),
          github: await _requiredGitHub(command, io),
        ),
      )).toJson();
    case 'action':
      return _executeAction(command, io, workingDirectory, smfPath);
    default:
      throw const SmfError(
        'A command is required. Run smf --help.',
        'COMMAND_REQUIRED',
      );
  }
}

Future<Object?> _executeAction(
  ArgResults command,
  CliIo io,
  String workingDirectory,
  String? smfPath,
) async {
  switch (command.option('phase')) {
    case 'pull-request':
      return (await planGitHubRelease(
        workingDirectory: workingDirectory,
        smfPath: smfPath,
        github: await _requiredGitHub(command, io),
      )).toJson();
    case 'release-candidate':
      final github = await _requiredGitHub(command, io);
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
          github: await _requiredGitHub(command, io),
        ),
      )).toJson();
  }
  throw const SmfError('Unsupported action phase.', 'INVALID_PHASE');
}

Future<int> runSmfCli(List<String> arguments, {CliIo? io}) async {
  final resolvedIo = io ?? CliIo.system();
  final parser = _parser();
  try {
    final results = parser.parse(arguments);
    if (results.flag('version')) {
      resolvedIo.writeOutput(smfVersion);
      return 0;
    }
    if (results.command?.flag('help') ?? false) {
      resolvedIo.writeOutput(
        '${_usage(parser)}\n${results.command!.name} options:\n'
        '${parser.commands[results.command!.name]!.usage}',
      );
      return 0;
    }
    if (results.flag('help') || results.command == null) {
      resolvedIo.writeOutput(_usage(parser));
      return results.flag('help') ? 0 : 64;
    }
    _printJson(resolvedIo, await _execute(results.command!, resolvedIo));
    return 0;
  } on FormatException catch (error) {
    resolvedIo.writeError('smf: ${error.message}');
    resolvedIo.writeError(_usage(parser));
    return 64;
  } on SmfError catch (error) {
    resolvedIo.writeError('smf [${error.code}]: ${error.message}');
    return 1;
  } on GitHubApiException catch (error) {
    resolvedIo.writeError(
      'smf [GITHUB_API]: GitHub ${error.method} ${error.path} '
      'failed (${error.statusCode}).',
    );
    return 1;
  } on dart_io.FileSystemException catch (error) {
    resolvedIo.writeError('smf [FILESYSTEM]: ${error.message}');
    return 1;
  }
}
