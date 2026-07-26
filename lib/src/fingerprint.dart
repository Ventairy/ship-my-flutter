import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

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
  final output = await git(root, const <String>['ls-files', '-z']);
  final files =
      output
          .split('\u0000')
          .where((String value) => value.isNotEmpty)
          .where(_shouldInclude)
          .toList()
        ..sort();
  final digest = await sha256.bind(_fingerprintBytes(root, files)).first;
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
      yield utf8.encode(await Link(filePath).target());
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
        final buildInputs = <String, Object?>{
          for (final key in <String>[
            'projectPath',
            'bundleId',
            'scheme',
            'buildArgs',
          ])
            if (ios.containsKey(key)) key: ios[key],
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

Future<String> fileSha256(String filePath) async {
  final digest = await sha256.bind(File(filePath).openRead()).first;
  return digest.toString();
}
