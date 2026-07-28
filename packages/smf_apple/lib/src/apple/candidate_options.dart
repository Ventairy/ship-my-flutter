import 'package:smf_apple/src/apple/candidate_dependencies.dart';
import 'package:smf_apple/src/apple/client.dart';
import 'package:smf_apple/src/models/apple_credentials.dart';
import 'package:smf_apple/src/models/signing_credentials.dart';
import 'package:smf_engine/smf_engine.dart';

/// Inputs and injectable adapters for creating an iOS candidate.
final class AppleCandidateOptions {
  /// Creates candidate options.
  const AppleCandidateOptions({
    required this.workingDirectory,
    required this.appleCredentials,
    required this.signingCredentials,
    this.smfPath,
    this.github,
    this.commitReceipt = true,
    this.client,
    this.dependencies = const AppleCandidateDependencies(),
  });

  /// Directory from which SMF discovers the target app.
  final String workingDirectory;

  /// Optional explicit `smf` directory, relative to [workingDirectory].
  final String? smfPath;

  /// App Store Connect credentials.
  final AppleCredentials appleCredentials;

  /// Distribution signing credentials.
  final AppleSigningCredentials signingCredentials;

  /// Optional GitHub context used to commit candidate evidence.
  final GitHubContext? github;

  /// Whether candidate evidence should be committed to the release branch.
  final bool commitReceipt;

  /// Optional App Store Connect client override.
  final AppStoreConnectApi? client;

  /// Candidate-build operation overrides.
  final AppleCandidateDependencies dependencies;
}
