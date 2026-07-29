import 'dart:io';

import 'package:yaml/yaml.dart';

/// Reads and parses one YAML file at [path].
final class YamlFile {
  /// Creates a YAML file boundary for [path].
  const YamlFile(this.path);

  /// Filesystem path read and parsed by this boundary.
  final String path;

  /// Reads the YAML stored at [path] and returns standard Dart collections.
  Future<Object?> read() async => parse(await File(path).readAsString());

  /// Parses [source] as YAML associated with [path].
  Object? parse(String source) => _normalize(loadYaml(source, sourceUrl: Uri.file(path)));

  static Object? _normalize(Object? value) => switch (value) {
    YamlMap() => _normalizeMap(value),
    YamlList() => <Object?>[
      for (final Object? element in value) _normalize(element),
    ],
    _ => value,
  };

  static Map<String, Object?> _normalizeMap(YamlMap value) {
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw FormatException(
          'YAML mapping keys must be strings; found ${key.runtimeType}.',
        );
      }
      result[key] = _normalize(entry.value);
    }
    return result;
  }
}
