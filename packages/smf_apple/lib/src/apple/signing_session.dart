import 'package:smf_apple/src/apple/installed_profile.dart';

/// Temporary signing assets installed for one build operation.
///
/// This deliberately avoids generated value semantics because it contains a
/// temporary keychain password that must never appear in diagnostics.
final class SigningSession {
  /// Creates a signing session.
  const SigningSession({
    required this.keychainPath,
    required this.keychainPassword,
    required this.profiles,
    required this.exportOptionsPath,
    required Future<void> Function() cleanup,
  }) : _cleanup = cleanup;

  /// Temporary keychain path.
  final String keychainPath;

  /// Temporary keychain password. Callers must never log this value.
  final String keychainPassword;

  /// Provisioning profiles installed by this session.
  final List<InstalledProfile> profiles;

  /// Generated Xcode export-options path.
  final String exportOptionsPath;

  final Future<void> Function() _cleanup;

  /// Removes every temporary signing asset created by this session.
  Future<void> cleanup() => _cleanup();
}
