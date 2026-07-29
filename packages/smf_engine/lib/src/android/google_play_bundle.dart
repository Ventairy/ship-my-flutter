/// One uploaded Android App Bundle.
final class GooglePlayBundle {
  /// Creates bundle evidence.
  const GooglePlayBundle({
    required this.versionCode,
    required this.sha256,
  });

  /// Manifest version code.
  final int versionCode;

  /// SHA-256 digest returned by Google Play.
  final String sha256;
}
