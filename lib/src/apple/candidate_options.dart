import '../models/apple_credentials.dart';
import '../models/github_context.dart';
import '../models/signing_credentials.dart';
import 'candidate_dependencies.dart';
import 'client.dart';

/// Inputs and injectable adapters for creating an iOS candidate.
final class CandidateOptions {
  /// Creates candidate options.
  const CandidateOptions({
    required this.root,
    required this.appleCredentials,
    required this.signingCredentials,
    this.github,
    this.commitReceipt = true,
    this.client,
    this.dependencies = const CandidateDependencies(),
  });

  /// Flutter repository root.
  final String root;

  /// App Store Connect credentials.
  final AppleCredentials appleCredentials;

  /// Distribution signing credentials.
  final SigningCredentials signingCredentials;

  /// Optional GitHub context used to commit candidate evidence.
  final GitHubContext? github;

  /// Whether candidate evidence should be committed to the release branch.
  final bool commitReceipt;

  /// Optional App Store Connect client override.
  final AppStoreConnectApi? client;

  /// Candidate-build operation overrides.
  final CandidateDependencies dependencies;
}
