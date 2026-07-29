import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/ios/client.dart';
import 'package:smf_engine/src/ios/models/apple_credentials.dart';
import 'package:smf_engine/src/ios/project.dart';

/// Inputs and injectable adapters for promoting an iOS release candidate.
final class ApplePromotionOptions {
  /// Creates promotion options.
  const ApplePromotionOptions({
    required this.workingDirectory,
    required this.appleCredentials,
    required this.github,
    this.smfPath,
    this.client,
    this.githubApi,
    this.resolveBundleIdentifier = AppleProject.resolveBundleId,
  });

  /// Directory from which SMF discovers the target app.
  final String workingDirectory;

  /// Optional explicit `smf` directory, relative to [workingDirectory].
  final String? smfPath;

  /// App Store Connect credentials.
  final AppleCredentials appleCredentials;

  /// GitHub repository and authentication context.
  final GitHubContext github;

  /// Optional App Store Connect client override.
  final AppStoreConnectApi? client;

  /// Optional GitHub client override.
  final GitHubApi? githubApi;

  /// Xcode bundle-identifier resolver.
  final Future<String> Function(
    String appRoot,
    IosConfig config, {
    String? flavor,
  })
  resolveBundleIdentifier;
}
