import 'package:smf_apple/src/apple/installed_profile.dart';

/// Temporary signing assets installed for one build operation.
///
/// This deliberately avoids generated value semantics because it contains a
/// temporary keychain password that must never appear in diagnostics.
final class AppleSigningSession {
  /// Creates a signing session.
  AppleSigningSession({
    required this.keychainPath,
    required this.keychainPassword,
    required List<AppleInstalledProfile> profiles,
    required this.exportOptionsPath,
    required Future<void> Function() cleanup,
  }) : profiles = List<AppleInstalledProfile>.unmodifiable(profiles),
       _cleanup = cleanup;

  /// Temporary keychain path.
  final String keychainPath;

  /// Temporary keychain password. Callers must never log this value.
  final String keychainPassword;

  /// Provisioning profiles installed by this session.
  final List<AppleInstalledProfile> profiles;

  /// Generated Xcode export-options path.
  final String exportOptionsPath;

  final Future<void> Function() _cleanup;

  /// Removes every temporary signing asset created by this session.
  Future<void> cleanup() => _cleanup();
}
