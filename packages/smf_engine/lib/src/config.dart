import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:smf_engine/src/error.dart';
import 'package:smf_engine/src/git.dart';
import 'package:smf_engine/src/json_file.dart';
import 'package:smf_engine/src/model.dart';
import 'package:smf_engine/src/paths.dart';
import 'package:smf_engine/src/yaml_file.dart';
import 'package:smf_hooks/smf_hooks_protocol.dart';
import 'package:yaml/yaml.dart';

part 'smf_state_files.dart';

/// Reads and validates all persisted state for one SMF application.
final class SmfState {
  const SmfState._();

  /// Reads the application configuration.
  static Future<SmfConfig> config([String? root]) {
    return _SmfStateFiles.loadConfig(root);
  }

  /// Reads generated platform release state.
  static Future<ManifestDto> manifest([String? root]) {
    return _SmfStateFiles.loadManifest(root);
  }

  /// Reads generated platform changelog state.
  static Future<ChangelogDto> changelog([String? root]) {
    return _SmfStateFiles.loadChangelog(root);
  }

  /// Reads optional localized store release notes.
  static Future<StoreReleaseNotes> storeReleaseNotes([String? root]) {
    return _SmfStateFiles.loadStoreReleaseNotes(root);
  }

  /// Parses and validates application configuration.
  static SmfConfig parseConfig(
    Object? value, {
    String source = 'configuration',
  }) {
    return _SmfStateFiles.validateConfig(value, source: source);
  }

  /// Parses and validates generated platform release state.
  static ManifestDto parseManifest(
    Object? value, {
    String source = 'manifest',
  }) {
    return _SmfStateFiles.validateManifest(value, source: source);
  }

  /// Parses and validates generated changelog state.
  static ChangelogDto parseChangelog(
    Object? value, {
    String source = 'changelog',
  }) {
    return _SmfStateFiles.validateChangelog(value, source: source);
  }

  /// Parses and validates localized store release notes.
  static StoreReleaseNotes parseStoreReleaseNotes(
    Object? value, {
    String source = 'store release notes',
  }) {
    return _SmfStateFiles.validateStoreReleaseNotes(value, source: source);
  }
}
