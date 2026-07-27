/// Android upload-key signing material.
///
/// This deliberately avoids generated value semantics so passwords and key
/// material are never included in diagnostics.
final class AndroidSigningCredentials {
  /// Creates Android upload-key credentials.
  const AndroidSigningCredentials({
    required this.keystoreBase64,
    required this.keyAlias,
    required this.keystorePassword,
    required this.keyPassword,
  });

  /// Base64-encoded JKS or PKCS12 upload keystore.
  final String keystoreBase64;

  /// Alias of the upload key inside the keystore.
  final String keyAlias;

  /// Password protecting the keystore.
  final String keystorePassword;

  /// Password protecting the selected upload key.
  final String keyPassword;
}
