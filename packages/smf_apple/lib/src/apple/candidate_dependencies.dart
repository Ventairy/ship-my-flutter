import 'package:smf_engine/smf_engine.dart';

import '../models/apple_credentials.dart';
import '../models/signing_credentials.dart';
import 'project.dart';
import 'signing.dart';
import 'upload.dart';

/// Installs signing material for a candidate build.
typedef InstallSigningAssets =
    Future<SigningSession> Function(
      SigningCredentials credentials,
      String bundleId,
    );

/// Produces an IPA for a planned release version and build number.
typedef BuildIosIpa =
    Future<String> Function({
      required String projectRoot,
      required String command,
      required String ipaOutputPath,
      required String version,
      required String buildNumber,
      required String exportOptionsPath,
      String? flavor,
    });

/// Uploads an IPA with App Store Connect credentials.
typedef UploadIpa =
    Future<void> Function(String ipaPath, AppleCredentials credentials);

/// Runs project preparation before candidate fingerprinting.
typedef RunBuildHook =
    Future<bool?> Function(
      String workingDirectory,
      SmfConfig config,
      String version,
    );

/// Injectable candidate-build operations.
final class CandidateDependencies {
  /// Creates candidate-build dependencies.
  const CandidateDependencies({
    this.installSigning = installSigningAssets,
    this.buildIpa = runIosBuildCommand,
    this.upload = uploadIpa,
    this.resolveBundleIdentifier = resolveBundleId,
    this.runBeforeBuild = runBeforeBuildHook,
    this.currentTime = _currentTime,
  });

  /// Signing installer.
  final InstallSigningAssets installSigning;

  /// IPA builder.
  final BuildIosIpa buildIpa;

  /// App Store Connect uploader.
  final UploadIpa upload;

  /// Xcode bundle-identifier resolver.
  final ResolveBundleId resolveBundleIdentifier;

  /// Repository-owned candidate preparation.
  final RunBuildHook runBeforeBuild;

  /// Supplies the receipt timestamp, primarily for deterministic workflows.
  final DateTime Function() currentTime;

  static DateTime _currentTime() => DateTime.now().toUtc();
}
