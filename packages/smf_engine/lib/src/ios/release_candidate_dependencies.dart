import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/ios/client.dart';
import 'package:smf_engine/src/ios/models/apple_credentials.dart';
import 'package:smf_engine/src/ios/models/resolved_signing_assets.dart';
import 'package:smf_engine/src/ios/models/signing_credentials.dart';
import 'package:smf_engine/src/ios/project.dart';
import 'package:smf_engine/src/ios/provisioning.dart';
import 'package:smf_engine/src/ios/signing.dart';
import 'package:smf_engine/src/ios/upload.dart';

/// Injectable release-candidate build operations.
final class AppleReleaseCandidateDependencies {
  /// Creates release-candidate build dependencies.
  const AppleReleaseCandidateDependencies({
    this.installSigning = AppleSigning.install,
    this.resolveProvisioning = AppleProvisioning.resolve,
    this.buildIpa = AppleBuild.run,
    this.upload = AppleBuild.upload,
    this.resolveBundleIdentifier = AppleProject.resolveBundleId,
    this.resolveSigningBundleIdentifiers = AppleProject.resolveSigningBundleIds,
    this.runBeforeBuild = RepositoryHooks.beforeBuild,
    this.currentTime = _currentTime,
  });

  /// Signing installer.
  final Future<AppleSigningSession> Function(
    AppleResolvedSigningAssets assets,
    String bundleId,
  )
  installSigning;

  /// Provisioning-profile resolver.
  final Future<AppleResolvedSigningAssets> Function({
    required AppleSigningCredentials credentials,
    required Set<String> bundleIds,
    required AppStoreConnectApi client,
  })
  resolveProvisioning;

  /// IPA builder.
  final Future<String> Function({
    required String projectRoot,
    required String command,
    required String ipaOutputPath,
    required String version,
    required String buildNumber,
    required String exportOptionsPath,
    String? flavor,
  })
  buildIpa;

  /// App Store Connect uploader.
  final Future<void> Function({
    required String ipaPath,
    required AppleCredentials credentials,
  })
  upload;

  /// Xcode bundle-identifier resolver.
  final Future<String> Function(
    String appRoot,
    IosConfig config, {
    String? flavor,
  })
  resolveBundleIdentifier;

  /// Xcode signed-target bundle-identifier resolver.
  final Future<Set<String>> Function(
    String appRoot, {
    required String mainBundleId,
    String? flavor,
  })
  resolveSigningBundleIdentifiers;

  /// Repository-owned release candidate preparation.
  final Future<bool> Function({required String workingDirectory}) runBeforeBuild;

  /// Supplies the receipt timestamp, primarily for deterministic workflows.
  final DateTime Function() currentTime;

  static DateTime _currentTime() => DateTime.now().toUtc();
}
