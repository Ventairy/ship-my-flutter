import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;

/// Content digests used to bind receipts to exact artifacts.
final class FileDigest {
  const FileDigest._();

  /// Calculates the SHA-256 digest of [filePath].
  static Future<String> sha256(String filePath) async {
    final digest = await crypto.sha256.bind(File(filePath).openRead()).first;
    return digest.toString();
  }
}
