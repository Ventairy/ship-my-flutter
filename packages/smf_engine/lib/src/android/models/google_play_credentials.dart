/// Google Play service-account credentials.
///
/// This deliberately avoids generated value semantics so private key material
/// is never included in diagnostics.
final class GooglePlayCredentials {
  /// Creates Google Play credentials from the complete service-account JSON.
  const GooglePlayCredentials({required this.serviceAccountJson});

  /// Raw service-account JSON. Callers must never log or persist this value.
  final String serviceAccountJson;
}
