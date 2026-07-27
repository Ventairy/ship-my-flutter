/// Apple distribution signing material.
///
/// This deliberately does not use generated value semantics so signing
/// secrets are never included in a generated `toString`.
final class SigningCredentials {
  /// Creates signing credentials.
  const SigningCredentials({
    required this.certificateBase64,
    required this.certificatePassword,
    required this.provisioningProfiles,
  });

  /// Base64-encoded distribution certificate and private key.
  final String certificateBase64;

  /// Password protecting the distribution certificate.
  final String certificatePassword;

  /// Encoded provisioning-profile mapping.
  final String provisioningProfiles;
}
