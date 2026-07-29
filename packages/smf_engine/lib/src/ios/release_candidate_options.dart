import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/ios/client.dart';
import 'package:smf_engine/src/ios/models/apple_credentials.dart';
import 'package:smf_engine/src/ios/models/signing_credentials.dart';
import 'package:smf_engine/src/ios/release_candidate_dependencies.dart';

/// Inputs and injectable adapters for creating an iOS release candidate.
final class AppleReleaseCandidateOptions {
  /// Creates release candidate options.
  const AppleReleaseCandidateOptions({
    required this.workingDirectory,
    required this.appleCredentials,
    required this.signingCredentials,
    this.smfPath,
    this.github,
    this.shouldCommitReceipt = true,
    this.client,
    this.dependencies = const AppleReleaseCandidateDependencies(),
  });

  /// Directory from which SMF discovers the target app.
  final String workingDirectory;

  /// Optional explicit `smf` directory, relative to [workingDirectory].
  final String? smfPath;

  /// App Store Connect credentials.
  final AppleCredentials appleCredentials;

  /// Distribution signing credentials.
  final AppleSigningCredentials signingCredentials;

  /// Optional GitHub context used to commit release candidate evidence.
  final GitHubContext? github;

  /// Whether release candidate evidence should be committed to the release branch.
  final bool shouldCommitReceipt;

  /// Optional App Store Connect client override.
  final AppStoreConnectApi? client;

  /// Release-candidate build operation overrides.
  final AppleReleaseCandidateDependencies dependencies;
}
