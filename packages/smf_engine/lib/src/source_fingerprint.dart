import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:path/path.dart' as p;

import 'package:smf_engine/src/config.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/yaml_file.dart';

/// Stable digest of every tracked input used to build an application.
final class SourceFingerprint {
  const SourceFingerprint._();

  /// Calculates the fingerprint for the app containing [workingDirectory].
  static Future<String> calculate(String workingDirectory) async {
    final paths = SmfPaths.resolve(workingDirectory);
    final root = paths.repositoryRoot;
    final config = await SmfState.config(paths.directory);
    final triggerPaths = paths.releaseTriggerPaths(config.releaseTriggerPaths);
    final smfRelative = p.relative(paths.directory, from: root).replaceAll(r'\', '/');
    final excluded = <String>{
      '$smfRelative/changelog.json',
      '$smfRelative/config.yaml',
      '$smfRelative/store-release-notes.json',
    };
    final output = await GitClient(root: root).runRaw(<String>[
      'ls-files',
      '-z',
      if (triggerPaths.isNotEmpty) '--',
      ...triggerPaths,
    ]);
    final files =
        output
            .split('\u0000')
            .where((value) => value.isNotEmpty)
            .where(
              (file) => !excluded.contains(file) && !file.startsWith('$smfRelative/release_candidates/'),
            )
            .toList()
          ..sort();
    final repositoryRoot = await Directory(root).resolveSymbolicLinks();
    final digest = await crypto.sha256.bind(_bytes(repositoryRoot, files, paths)).first;
    return digest.toString();
  }

  static Stream<List<int>> _bytes(
    String root,
    List<String> files,
    SmfPaths paths,
  ) async* {
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
        yield utf8.encode(
          await _validatedLinkTarget(root, filePath, files),
        );
      } else {
        yield* File(filePath).openRead();
      }
      yield const <int>[0];
    }

    final configPath = paths.config;
    try {
      final raw = await YamlFile(configPath).read();
      if (raw is Map<String, Object?>) {
        final platforms = raw['platforms'];
        final ios = platforms is Map<String, Object?> ? platforms['ios'] : null;
        final android = platforms is Map<String, Object?> ? platforms['android'] : null;
        final buildInputs = <String, Object?>{
          'app_id': raw['app_id'],
          if (raw.containsKey('flavor')) 'flavor': raw['flavor'],
          'release_trigger_paths': raw['release_trigger_paths'] ?? <Object?>[],
          if (ios is Map<String, Object?>)
            'ios': <String, Object?>{
              if (ios.containsKey('bundle_id')) 'bundle_id': ios['bundle_id'],
              'build_command': ios['build_command'] ?? 'auto',
              'ipa_output_path': ios['ipa_output_path'] ?? 'build/ios/ipa',
            },
          if (android is Map<String, Object?>)
            'android': <String, Object?>{
              if (android.containsKey('package_name')) 'package_name': android['package_name'],
              'build_command': android['build_command'] ?? 'auto',
              'aab_output_path': android['aab_output_path'] ?? 'build/app/outputs/bundle/release',
            },
        };
        final configMarker = p.relative(paths.config, from: root).replaceAll(r'\', '/');
        yield utf8.encode('$configMarker.build-inputs');
        yield const <int>[0];
        yield utf8.encode(jsonEncode(buildInputs));
        yield const <int>[0];
      }
    } on FileSystemException catch (error) {
      if (error.osError?.errorCode != 2) rethrow;
    }
  }

  static Future<String> _validatedLinkTarget(
    String repositoryRoot,
    String linkPath,
    List<String> trackedFiles,
  ) async {
    final link = Link(linkPath);
    final target = await link.target();
    final resolvedTarget = await link.resolveSymbolicLinks();
    SmfError.check(
      p.isWithin(repositoryRoot, resolvedTarget),
      'Tracked symlink ${p.relative(linkPath, from: repositoryRoot)} resolves '
      'outside the repository.',
      SmfErrorCode.sourceSymlinkEscape,
    );
    final relativeTarget = p.relative(resolvedTarget, from: repositoryRoot);
    SmfError.check(
      trackedFiles.contains(relativeTarget),
      'Tracked symlink ${p.relative(linkPath, from: repositoryRoot)} resolves '
      'to an untracked build input.',
      SmfErrorCode.sourceSymlinkUntracked,
    );
    return target;
  }
}
