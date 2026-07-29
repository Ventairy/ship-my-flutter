import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:smf_engine/src/error.dart';

/// Reads and writes one JSON file at [path].
final class JsonFile {
  /// Creates a JSON file boundary for [path].
  const JsonFile(this.path);

  /// Filesystem path read and written by this boundary.
  final String path;

  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  /// Reads the JSON object stored at [path].
  ///
  /// Throws [SmfErrorCode.jsonNotFound] when the file cannot be read and
  /// [SmfErrorCode.jsonMalformed] when its contents are not a JSON object.
  Future<Map<String, Object?>> read() async {
    try {
      final value = jsonDecode(await File(path).readAsString());
      if (value is! Map<String, Object?>) {
        throw FormatException('$path must contain a JSON object.');
      }
      return value;
    } on FileSystemException catch (error) {
      throw SmfError(
        'Could not read $path: ${error.message}',
        SmfErrorCode.jsonNotFound,
        cause: error,
      );
    } on FormatException catch (error) {
      throw SmfError(
        '$path contains malformed JSON.',
        SmfErrorCode.jsonMalformed,
        cause: error,
      );
    }
  }

  /// Writes the JSON object [value] with stable indentation and a trailing newline.
  Future<void> write(Map<String, Object?> value) async {
    final contents = '${_encoder.convert(value)}\n';
    final target = File(path);
    await target.parent.create(recursive: true);
    final targetType = await FileSystemEntity.type(
      path,
      followLinks: false,
    );
    final targetMode = targetType == FileSystemEntityType.file ? (await target.stat()).mode & 0x1ff : null;
    final temporary = File(
      '$path.smf-write-$pid-${Random.secure().nextInt(1 << 32)}.tmp',
    );
    try {
      await temporary.writeAsString(
        contents,
        mode: FileMode.writeOnly,
        flush: true,
      );
      if (targetMode != null && !Platform.isWindows) {
        final result = await Process.run('/bin/chmod', <String>[
          targetMode.toRadixString(8).padLeft(3, '0'),
          temporary.path,
        ]);
        if (result.exitCode != 0) {
          throw FileSystemException(
            'Could not preserve JSON file permissions',
            path,
          );
        }
      }
      await temporary.rename(path);
    } finally {
      if (await temporary.exists()) {
        await temporary.delete();
      }
    }
  }
}
