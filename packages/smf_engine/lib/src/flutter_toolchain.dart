import 'dart:io';

import 'package:path/path.dart' as p;

/// Resolves the Flutter executable used by repository-owned build commands.
final class FlutterToolchain {
  const FlutterToolchain._();

  /// Returns `fvm flutter` when the project is governed by FVM, otherwise
  /// returns `flutter`.
  ///
  /// Discovery walks from [projectRoot] to the nearest Git repository boundary
  /// and never adopts FVM configuration from a parent repository or home
  /// directory.
  static Future<String> resolveExecutable(String projectRoot) async {
    var directory = p.normalize(p.absolute(projectRoot));
    while (true) {
      final usesFvm =
          await File(p.join(directory, '.fvmrc')).exists() ||
          await File(
            p.join(directory, '.fvm', 'fvm_config.json'),
          ).exists();
      if (usesFvm) return 'fvm flutter';

      final gitBoundary =
          await File(p.join(directory, '.git')).exists() || await Directory(p.join(directory, '.git')).exists();
      final parent = p.dirname(directory);
      if (gitBoundary || parent == directory) return 'flutter';
      directory = parent;
    }
  }
}
