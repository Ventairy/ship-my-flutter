import 'package:smf_engine/src/android/android_release_candidate_dependencies.dart';
import 'package:smf_engine/src/android/client.dart';
import 'package:smf_engine/src/android/models/android_signing_credentials.dart';
import 'package:smf_engine/src/android/models/google_play_credentials.dart';
import 'package:smf_engine/src/models/github_context.dart';

/// Inputs for creating an Android release candidate.
final class AndroidReleaseCandidateOptions {
  /// Creates Android release candidate options.
  const AndroidReleaseCandidateOptions({
    required this.workingDirectory,
    required this.googlePlayCredentials,
    required this.signingCredentials,
    this.smfPath,
    this.github,
    this.shouldCommitReceipt = true,
    this.client,
    this.dependencies = const AndroidReleaseCandidateDependencies(),
  });

  /// Directory from which SMF discovers the target app.
  final String workingDirectory;

  /// Optional selected `smf` directory.
  final String? smfPath;

  /// Google Play service-account credentials.
  final GooglePlayCredentials googlePlayCredentials;

  /// Google Play upload-key credentials.
  final AndroidSigningCredentials signingCredentials;

  /// Optional GitHub context used to push release candidate evidence.
  final GitHubContext? github;

  /// Whether to commit and push the receipt.
  final bool shouldCommitReceipt;

  /// Optional Google Play client override.
  final GooglePlayApi? client;

  /// Release-candidate operation overrides.
  final AndroidReleaseCandidateDependencies dependencies;
}
