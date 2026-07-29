import 'dart:convert';
import 'dart:io';

import 'package:smf_engine/smf_engine.dart';

Future<void> main() async {
  final gitHubToken = Platform.environment['SMF_GITHUB_TOKEN'];
  if (gitHubToken == null || gitHubToken.isEmpty) {
    stderr.writeln('Set SMF_GITHUB_TOKEN before running this example.');
    exitCode = 64;
    return;
  }
  final paths = SmfPaths.resolve(Directory.current.path);
  await RepositoryValidator.validate(paths.directory);
  final config = await SmfState.config(paths.directory);
  final manifest = await SmfState.manifest(paths.directory);
  final plan =
      await ReleasePlanner(
        gitClient: GitClient(root: paths.repositoryRoot),
        appId: config.appId,
        releaseTriggerPaths: paths.releaseTriggerPaths(
          config.releaseTriggerPaths,
        ),
      ).create(
        manifest: manifest,
        platform: ReleasePlatform.ios,
        gitHubToken: gitHubToken,
      );
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(plan?.toJson()));
}
