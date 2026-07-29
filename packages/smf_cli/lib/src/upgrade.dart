import 'dart:convert';
import 'dart:io' as dart_io;

import 'package:pub_semver/pub_semver.dart';
import 'package:smf_engine/smf_engine.dart';

part 'smf_upgrade_service.dart';
part 'smf_upgrade_types.dart';

/// The installed SMF CLI version.
///
/// `packages/smf_cli/pubspec.yaml` remains the source of truth. A test keeps
/// this embedded value aligned so compiled `dart install` executables can
/// compare themselves with pub.dev without reading package source files.
const String smfCliVersion = '1.0.2'; // x-release-please-version
