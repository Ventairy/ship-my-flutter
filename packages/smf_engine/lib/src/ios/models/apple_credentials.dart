/// App Store Connect API credentials.
///
/// This deliberately does not use generated value semantics so private key
/// material is never included in a generated `toString`.
final class AppleCredentials {
  /// Creates App Store Connect API credentials.
  const AppleCredentials({
    required this.keyId,
    required this.issuerId,
    required this.privateKey,
  });

  /// App Store Connect API key identifier.
  final String keyId;

  /// App Store Connect issuer identifier.
  final String issuerId;

  /// Raw private key contents. Callers must never log or persist this value.
  final String privateKey;
}
