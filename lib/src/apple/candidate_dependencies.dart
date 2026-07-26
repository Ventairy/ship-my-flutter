import '../hooks.dart';
import '../models/apple_credentials.dart';
import '../models/ship_config.dart';
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
      required String artifactPath,
      required String version,
      required String buildNumber,
      required String exportOptionsPath,
      String? scheme,
    });

/// Uploads an IPA with App Store Connect credentials.
typedef UploadIpa =
    Future<void> Function(String ipaPath, AppleCredentials credentials);

/// Runs project preparation before candidate fingerprinting.
typedef RunCandidateHook =
    Future<void> Function(String root, ShipConfig config, String version);

/// Injectable candidate-build operations.
final class CandidateDependencies {
  /// Creates candidate-build dependencies.
  const CandidateDependencies({
    this.installSigning = installSigningAssets,
    this.buildIpa = runIosBuildCommand,
    this.upload = uploadIpa,
    this.resolveBundleIdentifier = resolveBundleId,
    this.runBeforeCandidate = runBeforeCandidateHook,
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
  final RunCandidateHook runBeforeCandidate;

  /// Supplies the receipt timestamp, primarily for deterministic workflows.
  final DateTime Function() currentTime;

  static DateTime _currentTime() => DateTime.now().toUtc();
}
