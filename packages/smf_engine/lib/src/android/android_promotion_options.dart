import 'package:smf_engine/src/android/client.dart';
import 'package:smf_engine/src/android/models/android_config.dart';
import 'package:smf_engine/src/android/models/google_play_credentials.dart';
import 'package:smf_engine/src/android/project.dart';
import 'package:smf_engine/src/github_api.dart';
import 'package:smf_engine/src/models/github_context.dart';

/// Inputs for promoting an exact Android release candidate.
final class AndroidPromotionOptions {
  /// Creates Android promotion options.
  const AndroidPromotionOptions({
    required this.workingDirectory,
    required this.googlePlayCredentials,
    required this.github,
    this.smfPath,
    this.client,
    this.githubApi,
    this.resolvePackage = AndroidProject.resolvePackageName,
  });

  /// Directory from which SMF discovers the target app.
  final String workingDirectory;

  /// Optional selected `smf` directory.
  final String? smfPath;

  /// Google Play service-account credentials.
  final GooglePlayCredentials googlePlayCredentials;

  /// GitHub repository and authentication context.
  final GitHubContext github;

  /// Optional Google Play client override.
  final GooglePlayApi? client;

  /// Optional GitHub API override.
  final GitHubApi? githubApi;

  /// Android application-ID resolver.
  final Future<String> Function(
    String appRoot,
    AndroidConfig config, {
    String? flavor,
  })
  resolvePackage;
}
