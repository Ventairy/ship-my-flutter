import 'package:smf_engine/src/android/build.dart';
import 'package:smf_engine/src/android/models/android_config.dart';
import 'package:smf_engine/src/android/models/android_signing_credentials.dart';
import 'package:smf_engine/src/android/project.dart';
import 'package:smf_engine/src/android/signing.dart';
import 'package:smf_engine/src/hooks.dart';

/// Release-candidate build operations injectable for deterministic tests.
final class AndroidReleaseCandidateDependencies {
  /// Creates Android release candidate dependencies.
  const AndroidReleaseCandidateDependencies({
    this.resolvePackage = AndroidProject.resolvePackageName,
    this.runBeforeBuild = RepositoryHooks.beforeBuild,
    this.installSigning = AndroidSigningSession.install,
    this.buildAab = AndroidBuild.run,
    this.currentTime = _currentTime,
  });

  /// Android application-ID resolver.
  final Future<String> Function(
    String appRoot,
    AndroidConfig config, {
    String? flavor,
  })
  resolvePackage;

  /// Repository-owned release candidate preparation.
  final Future<bool> Function({required String workingDirectory}) runBeforeBuild;

  /// Temporary upload-key installer.
  final Future<AndroidSigningSession> Function(
    AndroidSigningCredentials credentials,
  )
  installSigning;

  /// Signed AAB builder.
  final Future<String> Function({
    required String projectRoot,
    required String command,
    required String aabOutputPath,
    required String version,
    required String buildNumber,
    required AndroidSigningSession signing,
    required AndroidSigningCredentials credentials,
    String? flavor,
  })
  buildAab;

  /// Receipt clock.
  final DateTime Function() currentTime;

  static DateTime _currentTime() => DateTime.now().toUtc();
}
