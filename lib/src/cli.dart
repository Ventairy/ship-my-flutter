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
import 'release_plan.dart';
import 'validate.dart';

const String shipMyFlutterVersion = '0.1.0'; // x-release-please-version

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

ArgParser _parser() {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false)
    ..addFlag('version', negatable: false);
  parser.addCommand(
    'init',
    ArgParser()
      ..addOption('root', abbr: 'r')
      ..addOption('current-version')
      ..addOption('bundle-id')
      ..addFlag('force', negatable: false),
  );
  parser.addCommand('validate', ArgParser()..addOption('root', abbr: 'r'));
  parser.addCommand('plan', ArgParser()..addOption('root', abbr: 'r'));
  for (final name in const <String>['open-pr', 'release']) {
    parser.addCommand(
      name,
      ArgParser()
        ..addOption('root', abbr: 'r')
        ..addOption('repository')
        ..addOption('github-token-file'),
    );
  }
  for (final name in const <String>['candidate', 'testflight']) {
    parser.addCommand(
      name,
      ArgParser()
        ..addOption('root', abbr: 'r')
        ..addOption('repository')
        ..addOption('github-token-file')
        ..addFlag('commit-receipt', defaultsTo: true),
    );
  }
  for (final name in const <String>['promote', 'app-store']) {
    parser.addCommand(
      name,
      ArgParser()
        ..addOption('root', abbr: 'r')
        ..addOption('repository')
        ..addOption('github-token-file'),
    );
  }
  parser.addCommand(
    'action',
    ArgParser()
      ..addOption(
        'phase',
        allowed: const <String>['pull-request', 'release-candidate', 'ship'],
        mandatory: true,
      )
      ..addOption('root', abbr: 'r')
      ..addOption('repository')
      ..addOption('github-token-file'),
  );
  return parser;
}

String _usage(ArgParser parser) =>
    '''
ship-my-flutter $shipMyFlutterVersion

Platform-scoped Flutter release PRs, TestFlight candidates, and App Store
delivery.

Usage: ship-my-flutter <command> [options]

Commands:
  init         Create .ship-my-flutter and the starter GitHub workflow.
  validate     Validate configuration and repository safety invariants.
  plan         Print the next iOS release plan without changing files.
  open-pr      Open or update the iOS release PR.
  release      Alias for open-pr, suitable for custom automation.
  candidate    Build, sign, upload, and record the TestFlight candidate.
  testflight   Alias for candidate.
  promote      Promote the exact tested candidate after the release PR merges.
  app-store    Alias for promote.
  action       Machine protocol used by ship-my-flutter-action.

Global options:
${parser.usage}

Secrets are accepted through SHIP_MY_FLUTTER_* environment variables or the
documented *_PATH variables, never as command-line values.
''';

String _root(ArgResults command, CliIo io) =>
    p.normalize(p.absolute(command.option('root') ?? io.workingDirectory));

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
    'SHIP_MY_FLUTTER_GITHUB_TOKEN',
    'GITHUB_TOKEN',
    'INPUT_GITHUB_TOKEN',
  ]);
  if (path != null && path.isNotEmpty && environmentToken != null) {
    throw const ShipError(
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
    throw const ShipError(
      'A GitHub token is required. Set SHIP_MY_FLUTTER_GITHUB_TOKEN or '
          'GITHUB_TOKEN.',
      'GITHUB_TOKEN_REQUIRED',
    );
  }
  if (repository == null ||
      !RegExp(r'^[^/\s]+/[^/\s]+$').hasMatch(repository)) {
    throw const ShipError(
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
    throw const ShipError(
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
  final root = _root(command, io);
  switch (command.name) {
    case 'init':
      await initialize(
        InitOptions(
          root: root,
          currentVersion: command.option('current-version'),
          bundleId: command.option('bundle-id'),
          force: command.flag('force'),
        ),
      );
      return <String, Object?>{'initialized': true, 'root': root};
    case 'validate':
      await validateRepository(root);
      return const <String, Object?>{'valid': true};
    case 'plan':
      return (await createReleasePlan(
        root,
        await loadManifest(root),
        Platform.ios,
      ))?.toJson();
    case 'open-pr':
    case 'release':
      return (await planGitHubRelease(
        root: root,
        github: await _requiredGitHub(command, io),
      )).toJson();
    case 'candidate':
    case 'testflight':
      final github = await _optionalGitHub(command, io);
      return (await createIosCandidate(
        CandidateOptions(
          root: root,
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
          root: root,
          appleCredentials: await appleCredentialsFromEnvironment(
            io.environment,
          ),
          github: await _requiredGitHub(command, io),
        ),
      )).toJson();
    case 'action':
      return _executeAction(command, io, root);
    default:
      throw const ShipError(
        'A command is required. Run ship-my-flutter --help.',
        'COMMAND_REQUIRED',
      );
  }
}

Future<Object?> _executeAction(
  ArgResults command,
  CliIo io,
  String root,
) async {
  switch (command.option('phase')) {
    case 'pull-request':
      return (await planGitHubRelease(
        root: root,
        github: await _requiredGitHub(command, io),
      )).toJson();
    case 'release-candidate':
      final github = await _requiredGitHub(command, io);
      return (await createIosCandidate(
        CandidateOptions(
          root: root,
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
          root: root,
          appleCredentials: await appleCredentialsFromEnvironment(
            io.environment,
          ),
          github: await _requiredGitHub(command, io),
        ),
      )).toJson();
  }
  throw const ShipError('Unsupported action phase.', 'INVALID_PHASE');
}

Future<int> runShipMyFlutterCli(List<String> arguments, {CliIo? io}) async {
  final resolvedIo = io ?? CliIo.system();
  final parser = _parser();
  try {
    final results = parser.parse(arguments);
    if (results.flag('version')) {
      resolvedIo.writeOutput(shipMyFlutterVersion);
      return 0;
    }
    if (results.flag('help') || results.command == null) {
      resolvedIo.writeOutput(_usage(parser));
      return results.flag('help') ? 0 : 64;
    }
    _printJson(resolvedIo, await _execute(results.command!, resolvedIo));
    return 0;
  } on FormatException catch (error) {
    resolvedIo.writeError('ship-my-flutter: ${error.message}');
    resolvedIo.writeError(_usage(parser));
    return 64;
  } on ShipError catch (error) {
    resolvedIo.writeError('ship-my-flutter [${error.code}]: ${error.message}');
    return 1;
  } on GitHubApiException catch (error) {
    resolvedIo.writeError(
      'ship-my-flutter [GITHUB_API]: GitHub ${error.method} ${error.path} '
      'failed (${error.statusCode}).',
    );
    return 1;
  } on dart_io.FileSystemException catch (error) {
    resolvedIo.writeError('ship-my-flutter [FILESYSTEM]: ${error.message}');
    return 1;
  }
}
