import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'error.dart';
import 'git.dart';
import 'serialization.dart';

const Set<String> _excluded = <String>{
  '.ship-my-flutter/changelog.json',
  '.ship-my-flutter/config.yaml',
  '.ship-my-flutter/store-release-notes.json',
};

bool _shouldInclude(String file) =>
    !_excluded.contains(file) &&
    !file.startsWith('.ship-my-flutter/candidates/');

Future<String> sourceFingerprint(String root) async {
  final output = await GitClient(
    root: root,
  ).runRaw(const <String>['ls-files', '-z']);
  final files =
      output
          .split('\u0000')
          .where((String value) => value.isNotEmpty)
          .where(_shouldInclude)
          .toList()
        ..sort();
  final repositoryRoot = await Directory(root).resolveSymbolicLinks();
  final digest = await sha256
      .bind(_fingerprintBytes(repositoryRoot, files))
      .first;
  return digest.toString();
}

Stream<List<int>> _fingerprintBytes(String root, List<String> files) async* {
  for (final file in files) {
    final filePath = p.join(root, file);
    final type = await FileSystemEntity.type(filePath, followLinks: false);
    final isLink = type == FileSystemEntityType.link;
    final stats = await FileStat.stat(filePath);
    yield utf8.encode(file);
    yield const <int>[0];
    yield utf8.encode(isLink ? 'symlink' : '${stats.mode & 0x49}');
    yield const <int>[0];
    if (isLink) {
      yield utf8.encode(await _validatedLinkTarget(root, filePath, files));
    } else {
      yield* File(filePath).openRead();
    }
    yield const <int>[0];
  }

  final configPath = p.join(root, '.ship-my-flutter', 'config.yaml');
  try {
    final raw = await readYaml(configPath);
    if (raw is Map<Object?, Object?>) {
      final platforms = raw['platforms'];
      final ios = platforms is Map<Object?, Object?> ? platforms['ios'] : null;
      if (ios is Map<Object?, Object?>) {
        final hooks = raw['hooks'];
        final beforeBuild = hooks is Map<Object?, Object?>
            ? hooks['before_build']
            : null;
        final buildInputs = <String, Object?>{
          'app_path': raw['app_path'] ?? '.',
          if (raw.containsKey('flavor')) 'flavor': raw['flavor'],
          if (ios.containsKey('bundle_id')) 'bundle_id': ios['bundle_id'],
          'build_command': ios['build_command'] ?? 'auto',
          'ipa_output_path': ios['ipa_output_path'] ?? 'build/ios/ipa',
          if (beforeBuild is Map<Object?, Object?> &&
              beforeBuild.containsKey('run'))
            'before_build': beforeBuild['run'],
        };
        yield utf8.encode('.ship-my-flutter/config.build-inputs');
        yield const <int>[0];
        yield utf8.encode(jsonEncode(buildInputs));
        yield const <int>[0];
      }
    }
  } on FileSystemException catch (error) {
    if (error.osError?.errorCode != 2) rethrow;
  }
}

Future<String> _validatedLinkTarget(
  String repositoryRoot,
  String linkPath,
  List<String> trackedFiles,
) async {
  final link = Link(linkPath);
  final target = await link.target();
  final resolvedTarget = await link.resolveSymbolicLinks();
  invariant(
    p.isWithin(repositoryRoot, resolvedTarget),
    'Tracked symlink ${p.relative(linkPath, from: repositoryRoot)} resolves '
        'outside the repository.',
    'SOURCE_SYMLINK_ESCAPE',
  );
  final relativeTarget = p.relative(resolvedTarget, from: repositoryRoot);
  invariant(
    trackedFiles.contains(relativeTarget),
    'Tracked symlink ${p.relative(linkPath, from: repositoryRoot)} resolves '
        'to an untracked build input.',
    'SOURCE_SYMLINK_UNTRACKED',
  );
  return target;
}

Future<String> fileSha256(String filePath) async {
  final digest = await sha256.bind(File(filePath).openRead()).first;
  return digest.toString();
}
