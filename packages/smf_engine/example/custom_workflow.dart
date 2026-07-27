import 'dart:convert';
import 'dart:io';

import 'package:smf_engine/smf_engine.dart';

Future<void> main() async {
  final paths = resolveSmfPaths(Directory.current.path);
  await validateRepository(paths.directory);
  final manifest = await loadManifest(paths.directory);
  final plan = await createReleasePlan(
    paths.repositoryRoot,
    manifest,
    Platform.ios,
  );
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(plan?.toJson()));
}
