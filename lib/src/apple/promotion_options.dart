import '../github_api.dart';
import '../models/apple_credentials.dart';
import '../models/github_context.dart';
import 'client.dart';
import 'project.dart';

/// Inputs and injectable adapters for promoting an iOS candidate.
final class PromotionOptions {
  /// Creates promotion options.
  const PromotionOptions({
    required this.root,
    required this.appleCredentials,
    required this.github,
    this.client,
    this.githubApi,
    this.resolveBundleIdentifier = resolveBundleId,
  });

  /// Flutter repository root.
  final String root;

  /// App Store Connect credentials.
  final AppleCredentials appleCredentials;

  /// GitHub repository and authentication context.
  final GitHubContext github;

  /// Optional App Store Connect client override.
  final AppStoreConnectApi? client;

  /// Optional GitHub client override.
  final GitHubApi? githubApi;

  /// Xcode bundle-identifier resolver.
  final ResolveBundleId resolveBundleIdentifier;
}
