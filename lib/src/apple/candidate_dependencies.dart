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

/// Resolves locked Flutter dependencies before a candidate build.
typedef PrepareFlutterDependencies = Future<void> Function(String projectRoot);

/// Produces an IPA for a planned release version and build number.
typedef BuildFlutterIpa =
    Future<String> Function({
      required String projectRoot,
      required String version,
      required String buildNumber,
      required String exportOptionsPath,
      String? scheme,
      required List<String> buildArgs,
    });

/// Uploads an IPA with App Store Connect credentials.
typedef UploadIpa =
    Future<void> Function(String ipaPath, AppleCredentials credentials);

/// Injectable candidate-build operations.
final class CandidateDependencies {
  /// Creates candidate-build dependencies.
  const CandidateDependencies({
    this.installSigning = installSigningAssets,
    this.prepareDependencies = prepareFlutterDependencies,
    this.buildIpa = buildFlutterIpa,
    this.upload = uploadIpa,
    this.resolveBundleIdentifier = resolveBundleId,
    this.currentTime = _currentTime,
  });

  /// Signing installer.
  final InstallSigningAssets installSigning;

  /// Locked dependency resolver.
  final PrepareFlutterDependencies prepareDependencies;

  /// IPA builder.
  final BuildFlutterIpa buildIpa;

  /// App Store Connect uploader.
  final UploadIpa upload;

  /// Xcode bundle-identifier resolver.
  final ResolveBundleId resolveBundleIdentifier;

  /// Supplies the receipt timestamp, primarily for deterministic workflows.
  final DateTime Function() currentTime;

  static DateTime _currentTime() => DateTime.now().toUtc();
}
