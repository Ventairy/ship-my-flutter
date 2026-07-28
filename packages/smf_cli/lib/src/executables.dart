import 'dart:convert';
import 'dart:io' as dart_io;

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:smf_android/smf_android.dart' as android;
import 'package:smf_apple/smf_apple.dart' as apple;
import 'package:smf_cli/src/upgrade.dart';
import 'package:smf_engine/smf_engine.dart';

final class ExecutableIo {
  const ExecutableIo({
    required this.environment,
    required this.workingDirectory,
    required this.writeOutput,
    required this.writeError,
    this.upgradeService,
    this.checkForUpdates = false,
  });

  factory ExecutableIo.system() => ExecutableIo(
    environment: dart_io.Platform.environment,
    workingDirectory: dart_io.Directory.current.path,
    writeOutput: dart_io.stdout.writeln,
    writeError: dart_io.stderr.writeln,
    upgradeService: SmfUpgradeService.system(),
    checkForUpdates: true,
  );

  final Map<String, String> environment;
  final String workingDirectory;
  final void Function(Object? value) writeOutput;
  final void Function(Object? value) writeError;
  final SmfUpgradeService? upgradeService;
  final bool checkForUpdates;
}

/// Dispatches SMF command-line operations.
final class SmfExecutable {
  const SmfExecutable._();

  static const String _topLevelUsage = '''
SMF release automation

Usage:
  smf <command> [options]

Commands:
  init              Initialize SMF in a Flutter repository.
  release           Run one phase of the SMF release workflow.
  upgrade           Upgrade the installed SMF CLI to the latest version.
  migrate           Update files created by an older SMF CLI to the installed format.
  validate          Validate repository configuration.
''';

  /// Runs the top-level SMF command.
  static Future<int> run(
    List<String> arguments, {
    ExecutableIo? io,
  }) async {
    final resolvedIo = io ?? ExecutableIo.system();
    if (arguments.isEmpty || arguments.first == '--help' || arguments.first == '-h') {
      resolvedIo.writeOutput(_topLevelUsage);
      final exitCode = arguments.isEmpty ? 64 : 0;
      await _writeUpdateNotice(resolvedIo);
      return exitCode;
    }
    final command = arguments.first;
    final options = arguments.sublist(1);
    final int exitCode;
    switch (command) {
      case 'init':
        exitCode = await runInit(options, io: resolvedIo);
      case 'release':
        exitCode = await runRelease(options, io: resolvedIo);
      case 'upgrade':
        exitCode = await runUpgrade(options, io: resolvedIo);
      case 'migrate':
        exitCode = await runMigrate(options, io: resolvedIo);
      case 'validate':
        exitCode = await runValidate(options, io: resolvedIo);
      default:
        exitCode = _unknownCommand(command, resolvedIo);
    }
    if (command != 'upgrade') {
      await _writeUpdateNotice(resolvedIo);
    }
    return exitCode;
  }

  static Future<void> _writeUpdateNotice(ExecutableIo io) async {
    if (!io.checkForUpdates ||
        _environmentFlag(io.environment, 'CI') ||
        _environmentFlag(io.environment, 'SMF_NO_UPDATE_CHECK')) {
      return;
    }
    final service = io.upgradeService;
    if (service == null) return;
    try {
      final version = await service.newerVersion();
      if (version != null) {
        io.writeError(
          'SMF $version is available; this installation is '
          '$smfCliVersion. Run `smf upgrade` to update.',
        );
      }
    } on Object {
      // Update notices must never change or delay the requested operation.
    }
  }

  static bool _environmentFlag(
    Map<String, String> environment,
    String name,
  ) {
    final value = environment[name]?.trim().toLowerCase();
    return value == '1' || value == 'true' || value == 'yes';
  }

  static int _unknownCommand(String command, ExecutableIo io) {
    io.writeError('smf: unknown command "$command".');
    io.writeError(_topLevelUsage);
    return 64;
  }

  static ArgParser _options() => ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this command help.',
    );

  static String _usage(String name, String description, ArgParser parser) {
    final credentialGuidance = parser.options.containsKey('github-token')
        ? '''

Credentials can be passed as command options or SMF_* environment variables.
Environment variables are safer because command arguments may be observable.
'''
        : '';
    return '''
Usage: smf ${name.replaceAll('_', '-')} [options]

$description

Options:
${parser.usage}
$credentialGuidance
''';
  }

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

  static String? _environmentValue(
    Map<String, String> environment,
    String name,
  ) {
    final value = environment[name]?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static String? _credentialValue({
    required ArgResults arguments,
    required Map<String, String> environment,
    required String option,
    required String environmentName,
  }) {
    final argumentValue = arguments.option(option)?.trim();
    final environmentValue = _environmentValue(
      environment,
      environmentName,
    );
    if (argumentValue != null && argumentValue.isNotEmpty && environmentValue != null) {
      throw SmfError(
        'Set only one credential source: --$option or $environmentName.',
        'CONFLICTING_CREDENTIAL',
      );
    }
    if (argumentValue != null && argumentValue.isEmpty) {
      throw SmfError(
        '--$option must not be empty.',
        'INVALID_CREDENTIAL',
      );
    }
    return argumentValue ?? environmentValue;
  }

  static Map<String, String> _credentialEnvironment(
    ArgResults arguments,
    Map<String, String> environment, {
    required bool includeSigning,
  }) {
    final result = Map<String, String>.of(environment);
    for (final entry in <String, String>{
      'app-store-connect-key-id': 'SMF_APP_STORE_CONNECT_KEY_ID',
      'app-store-connect-issuer-id': 'SMF_APP_STORE_CONNECT_ISSUER_ID',
      'app-store-connect-auth-key-base64': 'SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64',
      'google-play-service-account-json': 'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON',
      if (includeSigning) ...<String, String>{
        'ios-certificate-base64': 'SMF_IOS_CERTIFICATE_BASE64',
        'ios-certificate-password': 'SMF_IOS_CERTIFICATE_PASSWORD',
        'android-keystore-base64': 'SMF_ANDROID_KEYSTORE_BASE64',
        'android-key-alias': 'SMF_ANDROID_KEY_ALIAS',
        'android-keystore-password': 'SMF_ANDROID_KEYSTORE_PASSWORD',
        'android-key-password': 'SMF_ANDROID_KEY_PASSWORD',
      },
    }.entries) {
      final value = _credentialValue(
        arguments: arguments,
        environment: environment,
        option: entry.key,
        environmentName: entry.value,
      );
      if (value != null) result[entry.value] = value;
    }
    return result;
  }

  static String? _token(ArgResults arguments, ExecutableIo io) => _credentialValue(
    arguments: arguments,
    environment: io.environment,
    option: 'github-token',
    environmentName: 'SMF_GITHUB_TOKEN',
  );

  static ArgParser _addStoreCredentialOptions(
    ArgParser parser, {
    required bool includeSigning,
  }) {
    parser
      ..addOption(
        'app-store-connect-key-id',
        valueHelp: 'value',
        help:
            'App Store Connect API key ID. Alternatively set '
            'SMF_APP_STORE_CONNECT_KEY_ID.',
      )
      ..addOption(
        'app-store-connect-issuer-id',
        valueHelp: 'value',
        help:
            'App Store Connect issuer ID. Alternatively set '
            'SMF_APP_STORE_CONNECT_ISSUER_ID.',
      )
      ..addOption(
        'app-store-connect-auth-key-base64',
        valueHelp: 'base64',
        help:
            'Base64 App Store Connect .p8 key. Alternatively set '
            'SMF_APP_STORE_CONNECT_AUTH_KEY_BASE64.',
      )
      ..addOption(
        'google-play-service-account-json',
        valueHelp: 'json',
        help:
            'Complete Google Play service-account JSON. Alternatively set '
            'SMF_GOOGLE_PLAY_SERVICE_ACCOUNT_JSON.',
      );
    if (!includeSigning) return parser;
    parser
      ..addOption(
        'ios-certificate-base64',
        valueHelp: 'base64',
        help:
            'Base64 Apple Distribution .p12. Alternatively set '
            'SMF_IOS_CERTIFICATE_BASE64.',
      )
      ..addOption(
        'ios-certificate-password',
        valueHelp: 'value',
        help:
            'Apple Distribution .p12 password. Alternatively set '
            'SMF_IOS_CERTIFICATE_PASSWORD.',
      )
      ..addOption(
        'android-keystore-base64',
        valueHelp: 'base64',
        help:
            'Base64 Android upload keystore. Alternatively set '
            'SMF_ANDROID_KEYSTORE_BASE64.',
      )
      ..addOption(
        'android-key-alias',
        valueHelp: 'value',
        help:
            'Android upload-key alias. Alternatively set '
            'SMF_ANDROID_KEY_ALIAS.',
      )
      ..addOption(
        'android-keystore-password',
        valueHelp: 'value',
        help:
            'Android upload-keystore password. Alternatively set '
            'SMF_ANDROID_KEYSTORE_PASSWORD.',
      )
      ..addOption(
        'android-key-password',
        valueHelp: 'value',
        help:
            'Android upload-key password. Alternatively set '
            'SMF_ANDROID_KEY_PASSWORD.',
      );
    return parser;
  }

  static Future<String?> _repository(
    ArgResults arguments,
    ExecutableIo io, {
    required bool inferFromGit,
  }) async {
    final override = arguments.option('repository');
    if (override != null) return override.trim();
    final environmentRepository = _environmentValue(
      io.environment,
      'SMF_GITHUB_REPOSITORY',
    );
    if (environmentRepository != null || !inferFromGit) {
      return environmentRepository;
    }
    final remote = await GitClient(
      root: _workingDirectory(io),
    ).run(const <String>['remote', 'get-url', 'origin'], allowFailure: true);
    return _githubRepositoryFromRemote(remote);
  }

  static String? _githubRepositoryFromRemote(String remote) {
    final value = remote.trim();
    if (value.isEmpty) return null;
    final scp = RegExp(
      r'^(?:[^@\s]+@)?github\.com:([^/\s]+)/([^/\s]+?)(?:\.git)?/?$',
      caseSensitive: false,
    ).firstMatch(value);
    if (scp != null) return '${scp.group(1)}/${scp.group(2)}';

    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.toLowerCase() != 'github.com') return null;
    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (segments.length != 2) return null;
    final repository = segments[1].endsWith('.git') ? segments[1].substring(0, segments[1].length - 4) : segments[1];
    if (segments[0].isEmpty || repository.isEmpty) return null;
    return '${segments[0]}/$repository';
  }

  static Future<GitHubContext?> _optionalGitHub(
    ArgResults arguments,
    ExecutableIo io, {
    bool inferRepositoryFromGit = false,
  }) async {
    final token = _token(arguments, io);
    final repository = await _repository(
      arguments,
      io,
      inferFromGit: inferRepositoryFromGit,
    );
    if (repository == null && inferRepositoryFromGit) {
      throw const SmfError(
        'Could not infer a GitHub repository from SMF_GITHUB_REPOSITORY or the '
            'current Git origin remote. Pass --repository owner/name.',
        'GITHUB_REPOSITORY_REQUIRED',
      );
    }
    if (token == null && repository == null) return null;
    if (token == null) {
      throw const SmfError(
        'A GitHub token is required. Set --github-token or '
            'SMF_GITHUB_TOKEN.',
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
    ExecutableIo io, {
    bool inferRepositoryFromGit = false,
  }) async {
    final context = await _optionalGitHub(
      arguments,
      io,
      inferRepositoryFromGit: inferRepositoryFromGit,
    );
    if (context == null) {
      throw const SmfError(
        'GitHub credentials are required. Set --github-token or '
            'SMF_GITHUB_TOKEN, and provide --repository or '
            'SMF_GITHUB_REPOSITORY when it cannot be inferred from Git.',
        'GITHUB_CREDENTIALS_REQUIRED',
      );
    }
    return context;
  }

  static ArgParser _githubOptions({
    bool inferRepositoryFromGit = false,
  }) => _options()
    ..addOption(
      'smf-path',
      valueHelp: 'path',
      help:
          'Repository-relative path to the app-owned smf directory. Required '
          'when the repository contains multiple SMF apps.',
    )
    ..addOption(
      'repository',
      valueHelp: 'owner/name',
      help: inferRepositoryFromGit
          ? 'Override the GitHub repository that owns the release. Without '
                'this option, SMF reads SMF_GITHUB_REPOSITORY and then the '
                'current Git origin remote.'
          : 'GitHub repository that owns the release. Defaults to '
                'SMF_GITHUB_REPOSITORY.',
    )
    ..addOption(
      'github-token',
      valueHelp: 'value',
      help:
          'GitHub token used for release state and repository writes. '
          'Alternatively set SMF_GITHUB_TOKEN.',
    );

  static Future<int> runInit(List<String> arguments, {ExecutableIo? io}) {
    final parser = _options()
      ..addOption(
        'app-path',
        valueHelp: 'path',
        help:
            'Flutter app directory relative to the current directory. '
            'Defaults to the current directory.',
      )
      ..addOption(
        'app-id',
        valueHelp: 'id',
        help:
            'Permanent repository-unique ID used in release branches, tags, '
            'workflows, and GitHub environments. Defaults to the Flutter '
            'package name.',
      )
      ..addOption(
        'version',
        valueHelp: 'major.minor.patch',
        help:
            'Initial stable version for every detected platform. Cannot be '
            'combined with --ios-version or --android-version.',
      )
      ..addOption(
        'ios-version',
        valueHelp: 'major.minor.patch',
        help:
            'Initial stable iOS marketing version. Overrides automatic '
            'detection for iOS.',
      )
      ..addOption(
        'android-version',
        valueHelp: 'major.minor.patch',
        help:
            'Initial stable Android marketing version. Overrides automatic '
            'detection for Android.',
      )
      ..addOption(
        'ios-bundle-id',
        valueHelp: 'bundle-id',
        help:
            'App Store bundle identifier, for example com.example.app. '
            'Recommended when iOS is enabled.',
      )
      ..addOption(
        'android-package-name',
        valueHelp: 'package-name',
        help:
            'Google Play application ID, for example com.example.app. '
            'Recommended when Android is enabled.',
      )
      ..addFlag(
        'force',
        negatable: false,
        help:
            'Replace the generated SMF configuration and workflow when the '
            'app is already initialized.',
      )
      ..addFlag(
        'github-actions',
        negatable: false,
        help:
            'Regenerate only the GitHub Actions workflow for an already '
            'initialized app; preserve configuration and release state.',
      )
      ..addFlag(
        'no-github-actions',
        negatable: false,
        help:
            'Initialize SMF without generating a GitHub Actions workflow. Use '
            'the phased CLI manually for release operations.',
      );
    return _runExecutable(
      name: 'init',
      description:
          'Create smf/config.yaml and, unless disabled, the starter GitHub '
          'Actions workflow.',
      arguments: arguments,
      parser: parser,
      io: io,
      operation: (arguments, io) async {
        final appRoot = _initAppRoot(arguments, io);
        final githubActionsOnly = arguments.flag('github-actions');
        final noGitHubActions = arguments.flag('no-github-actions');
        SmfError.check(
          !(githubActionsOnly && noGitHubActions),
          '--github-actions cannot be combined with --no-github-actions.',
          'INVALID_INIT_OPTIONS',
        );
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
            githubActions: !noGitHubActions,
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

  static Future<int> runUpgrade(List<String> arguments, {ExecutableIo? io}) {
    final parser = _options();
    return _runExecutable(
      name: 'upgrade',
      description:
          'Replace this installed SMF CLI with the latest version published '
          'on pub.dev.',
      arguments: arguments,
      parser: parser,
      io: io,
      operation: (_, io) async {
        final service = io.upgradeService ?? SmfUpgradeService.system();
        return service.upgrade();
      },
    );
  }

  static Future<int> runMigrate(List<String> arguments, {ExecutableIo? io}) {
    final parser = _options()
      ..addOption(
        'smf-path',
        valueHelp: 'path',
        help:
            'Repository-relative path to the app-owned smf directory. Required '
            'when the repository contains multiple SMF apps.',
      )
      ..addOption(
        'app-id',
        valueHelp: 'id',
        help: 'App ID to use only when an older configuration cannot infer one.',
      )
      ..addFlag(
        'config',
        negatable: false,
        help:
            'Migrate only smf/config.yaml. With no migration target flags, all '
            'file groups are migrated.',
      )
      ..addFlag(
        'github-actions',
        negatable: false,
        help:
            'Regenerate only the app-scoped GitHub Actions workflow. With no '
            'migration target flags, all file groups are migrated.',
      )
      ..addFlag(
        'registry',
        negatable: false,
        help:
            'Migrate only machine-owned manifests, changelogs, store notes, '
            'and candidate receipts. With no migration target flags, all file '
            'groups are migrated.',
      );
    return _runExecutable(
      name: 'migrate',
      description:
          'Update SMF files created by an older CLI to the format required by '
          'the currently installed CLI, such as when configuration fields or '
          'generated workflows change. Run smf upgrade first, then run this '
          'command.',
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
    final parser = _options()
      ..addOption(
        'smf-path',
        valueHelp: 'path',
        help:
            'Repository-relative path to the app-owned smf directory. Required '
            'when the repository contains multiple SMF apps.',
      );
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

  /// Runs one release workflow phase.
  static Future<int> runRelease(
    List<String> arguments, {
    ExecutableIo? io,
  }) {
    final parser =
        _addStoreCredentialOptions(
            _githubOptions(inferRepositoryFromGit: true),
            includeSigning: true,
          )
          ..addOption(
            'phase',
            mandatory: true,
            help:
                'Release workflow phase: pull-request, release-candidate, or '
                'ship.',
          )
          ..addOption(
            'platform',
            valueHelp: 'ios|android',
            help:
                'Optional platform filter: ios or android. Omit it to process '
                'every eligible platform.',
          )
          ..addOption('working-directory', hide: true);
    return _runExecutable(
      name: 'release',
      description:
          'Run one phase of the SMF release workflow. Without --platform, the '
          'phase processes every eligible platform.',
      arguments: arguments,
      parser: parser,
      io: io,
      operation: (arguments, io) async {
        if (!arguments.wasParsed('phase')) {
          throw const FormatException(
            'Missing required option "--phase". Choose pull-request, '
            'release-candidate, or ship.',
          );
        }
        final phase = arguments.option('phase')!;
        if (phase != 'pull-request' && phase != 'release-candidate' && phase != 'ship') {
          throw FormatException(
            'Unsupported phase "$phase". Choose pull-request, '
            'release-candidate, or ship.',
          );
        }
        final selected = arguments.option('platform');
        final selectedPlatform = selected == null ? null : Platform.parse(selected);
        final workingDirectory = _workingDirectory(
          io,
          arguments.option('working-directory'),
        );
        final smfPath = _smfPath(arguments);
        final github = await _requiredGitHub(
          arguments,
          io,
          inferRepositoryFromGit: true,
        );
        switch (phase) {
          case 'pull-request':
            return (await _prepareRelease(
              workingDirectory: workingDirectory,
              smfPath: smfPath,
              github: github,
              selectedPlatform: selectedPlatform,
            )).toJson();
          case 'release-candidate':
            final releases = await _createCandidates(
              workingDirectory: workingDirectory,
              smfPath: smfPath,
              github: github,
              environment: _credentialEnvironment(
                arguments,
                io.environment,
                includeSigning: true,
              ),
              selectedPlatform: selectedPlatform,
            );
            return <String, Object?>{
              'phase': 'release-candidate',
              'releases': releases,
            };
          case 'ship':
            final releases = await _shipFromRemote(
              workingDirectory: workingDirectory,
              smfPath: smfPath,
              github: github,
              environment: _credentialEnvironment(
                arguments,
                io.environment,
                includeSigning: false,
              ),
              selectedPlatform: selectedPlatform,
            );
            return <String, Object?>{
              'phase': 'ship',
              'releases': releases,
            };
        }
        throw const SmfError('Unsupported release phase.', 'INVALID_PHASE');
      },
    );
  }

  static Future<List<Map<String, Object?>>> _shipFromRemote({
    required String workingDirectory,
    required String? smfPath,
    required GitHubContext github,
    required Map<String, String> environment,
    Platform? selectedPlatform,
  }) => _withRemoteTargetCheckout(
    workingDirectory: workingDirectory,
    smfPath: smfPath,
    github: github,
    operation:
        (
          remoteWorkingDirectory,
          remoteSmfPath,
          config,
          manifest,
          gitClient,
        ) async {
          final platforms = <Platform>[];
          for (final platform in config.enabledPlatforms) {
            final state = manifest.forPlatform(platform);
            final tag = ReleaseReference.tag(
              config.appId,
              platform,
              state.version,
            );
            if ((selectedPlatform == null || platform == selectedPlatform) &&
                state.pendingRelease &&
                !await gitClient.remoteTagExists(tag, github.token)) {
              platforms.add(platform);
            }
          }
          SmfError.check(
            platforms.isNotEmpty,
            'No created release is ready to ship on the remote '
                '${config.targetBranch} branch. Run the pull-request and '
                'release-candidate phases, test the candidates, and merge the '
                'release PR first.',
            'NO_RELEASE_TO_SHIP',
          );
          final releases = <Map<String, Object?>>[];
          for (final platform in platforms) {
            releases.add(
              await _shipPlatform(
                platform: platform,
                workingDirectory: remoteWorkingDirectory,
                smfPath: remoteSmfPath,
                github: github,
                environment: environment,
              ),
            );
          }
          return releases;
        },
  );

  static Future<T> _withRemoteTargetCheckout<T>({
    required String workingDirectory,
    required String? smfPath,
    required GitHubContext github,
    required Future<T> Function(
      String workingDirectory,
      String? smfPath,
      SmfConfig config,
      SmfManifest manifest,
      GitClient gitClient,
    )
    operation,
  }) async {
    final localGit = GitClient(root: workingDirectory);
    final repositoryRoot = await localGit.run(
      const <String>['rev-parse', '--show-toplevel'],
    );
    final remoteUrl = await localGit.run(
      const <String>['remote', 'get-url', 'origin'],
    );
    final defaultBranch = await localGit.remoteDefaultBranch(github.token);
    final canonicalWorkingDirectory = dart_io.Directory(
      workingDirectory,
    ).resolveSymbolicLinksSync();
    final canonicalRepositoryRoot = dart_io.Directory(
      repositoryRoot,
    ).resolveSymbolicLinksSync();
    final relativeWorkingDirectory = p.relative(
      canonicalWorkingDirectory,
      from: canonicalRepositoryRoot,
    );
    SmfError.check(
      relativeWorkingDirectory == '.' ||
          (!p.isAbsolute(relativeWorkingDirectory) && p.split(relativeWorkingDirectory).first != '..'),
      'The working directory must stay inside the current Git repository.',
      'INVALID_WORKING_DIRECTORY',
    );

    final temporaryDirectory = await dart_io.Directory.systemTemp.createTemp(
      'smf-ship-',
    );
    final checkoutRoot = p.join(temporaryDirectory.path, 'repository');
    var failed = true;
    try {
      await localGit.authenticated(<String>[
        'clone',
        '--branch',
        defaultBranch,
        '--single-branch',
        '--no-tags',
        remoteUrl,
        checkoutRoot,
      ], github.token);
      final remoteWorkingDirectory = relativeWorkingDirectory == '.'
          ? checkoutRoot
          : p.join(checkoutRoot, relativeWorkingDirectory);
      var paths = SmfPaths.resolve(
        remoteWorkingDirectory,
        smfPath: smfPath,
      );
      var config = await SmfState.config(paths.directory);
      final gitClient = GitClient(root: checkoutRoot);
      if (config.targetBranch != defaultBranch) {
        final targetRefSpec = 'refs/heads/${config.targetBranch}:refs/remotes/origin/${config.targetBranch}';
        await gitClient.authenticated(<String>[
          'fetch',
          'origin',
          targetRefSpec,
        ], github.token);
        await gitClient.run(<String>[
          'checkout',
          '-B',
          config.targetBranch,
          'origin/${config.targetBranch}',
        ]);
        paths = SmfPaths.resolve(
          remoteWorkingDirectory,
          smfPath: smfPath,
        );
        final targetConfig = await SmfState.config(paths.directory);
        SmfError.check(
          targetConfig.targetBranch == config.targetBranch,
          'The remote target branch changed its own target_branch from '
              '${config.targetBranch} to ${targetConfig.targetBranch}. Update '
              'the default branch configuration before shipping.',
          'REMOTE_TARGET_BRANCH_MISMATCH',
        );
        config = targetConfig;
      }
      final manifest = await SmfState.manifest(paths.directory);
      final result = await operation(
        remoteWorkingDirectory,
        smfPath,
        config,
        manifest,
        gitClient,
      );
      failed = false;
      return result;
    } finally {
      if (temporaryDirectory.existsSync()) {
        try {
          await temporaryDirectory.delete(recursive: true);
        } on dart_io.FileSystemException {
          if (!failed) rethrow;
        }
      }
    }
  }

  static Future<Map<String, Object?>> _createCandidate({
    required Platform platform,
    required String workingDirectory,
    required String? smfPath,
    required GitHubContext github,
    required Map<String, String> environment,
  }) async {
    final appleCredentials = apple.AppleCredentialProvider(
      environment: environment,
    );
    final androidCredentials = android.AndroidCredentialProvider(
      environment: environment,
    );
    return switch (platform) {
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
  }

  static Future<List<Map<String, Object?>>> _createCandidates({
    required String workingDirectory,
    required String? smfPath,
    required GitHubContext github,
    required Map<String, String> environment,
    Platform? selectedPlatform,
  }) async {
    final paths = SmfPaths.resolve(
      workingDirectory,
      smfPath: smfPath,
    );
    final (config, manifest) = await (
      SmfState.config(paths.directory),
      SmfState.manifest(paths.directory),
    ).wait;
    final platforms = <Platform>[
      for (final platform in config.enabledPlatforms)
        if ((selectedPlatform == null || platform == selectedPlatform) && manifest.forPlatform(platform).pendingRelease)
          platform,
    ];
    SmfError.check(
      platforms.isNotEmpty,
      selectedPlatform == null
          ? 'No release candidate is pending on the current release branch.'
          : 'No ${selectedPlatform.value} release candidate is pending on the '
                'current release branch.',
      'NO_RELEASE_CANDIDATE',
    );
    final releases = <Map<String, Object?>>[];
    for (final platform in platforms) {
      releases.add(
        await _createCandidate(
          platform: platform,
          workingDirectory: workingDirectory,
          smfPath: smfPath,
          github: github,
          environment: environment,
        ),
      );
    }
    return releases;
  }

  static Future<CommandResult> _prepareRelease({
    required String workingDirectory,
    required String? smfPath,
    required GitHubContext github,
    Platform? selectedPlatform,
  }) => const ReleaseOrchestrator().plan(
    workingDirectory: workingDirectory,
    smfPath: smfPath,
    github: github,
    selectedPlatform: selectedPlatform,
  );

  static Future<Map<String, Object?>> _shipPlatform({
    required Platform platform,
    required String workingDirectory,
    required String? smfPath,
    required GitHubContext github,
    required Map<String, String> environment,
  }) async {
    final appleCredentials = apple.AppleCredentialProvider(
      environment: environment,
    );
    final androidCredentials = android.AndroidCredentialProvider(
      environment: environment,
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
  }
}
