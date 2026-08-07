import 'package:smf_engine/src/ios/models/signing_credentials.dart';

/// Signing material after SMF has resolved every signed Apple target.
///
/// This deliberately avoids generated value semantics so signing secrets are
/// never included in a generated `toString`.
final class AppleResolvedSigningAssets {
  /// Creates resolved signing material.
  AppleResolvedSigningAssets({
    required this.credentials,
    required Map<String, String> profilesByBundleId,
  }) : profilesByBundleId = Map<String, String>.unmodifiable(
         profilesByBundleId,
       );

  /// Distribution certificate and its password.
  final AppleSigningCredentials credentials;

  /// Apple-managed signing data keyed by exact bundle identifier.
  final Map<String, String> profilesByBundleId;
}
