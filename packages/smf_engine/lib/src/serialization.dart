import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

/// Reads and writes SMF's JSON and YAML filesystem boundaries.
final class SmfFileSystem {
  const SmfFileSystem._();

  static const JsonEncoder _jsonEncoder = JsonEncoder.withIndent('  ');

  /// Reads and decodes one JSON file.
  static Future<Object?> readJson(String filePath) async {
    final source = await File(filePath).readAsString();
    return jsonDecode(source);
  }

  /// Writes one JSON value with stable indentation and a trailing newline.
  static Future<void> writeJson(String filePath, Object? value) async {
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString('${_jsonEncoder.convert(value)}\n');
  }

  /// Reads one YAML file and narrows YAML collections to Dart collections.
  static Future<Object?> readYaml(String filePath) async {
    final source = await File(filePath).readAsString();
    return parseYaml(source, sourceUrl: Uri.file(filePath));
  }

  /// Parses YAML and narrows YAML collections to string-keyed Dart values.
  static Object? parseYaml(String source, {Uri? sourceUrl}) => _normalizeYaml(loadYaml(source, sourceUrl: sourceUrl));

  /// Whether any filesystem entity currently exists at [filePath].
  static Future<bool> exists(String filePath) async =>
      await FileSystemEntity.type(filePath) != FileSystemEntityType.notFound;

  static Object? _normalizeYaml(Object? value) => switch (value) {
    YamlMap() => _normalizeYamlMap(value),
    YamlList() => <Object?>[
      for (final Object? element in value) _normalizeYaml(element),
    ],
    _ => value,
  };

  static Map<String, Object?> _normalizeYamlMap(YamlMap value) {
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw FormatException(
          'YAML mapping keys must be strings; found ${key.runtimeType}.',
        );
      }
      result[key] = _normalizeYaml(entry.value);
    }
    return result;
  }
}
