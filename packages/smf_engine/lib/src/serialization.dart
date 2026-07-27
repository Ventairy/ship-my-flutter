import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

Future<Object?> readJson(String filePath) async {
  final source = await File(filePath).readAsString();
  return jsonDecode(source);
}

Future<void> writeJson(String filePath, Object? value) async {
  final file = File(filePath);
  await file.parent.create(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(value)}\n');
}

Future<Object?> readYaml(String filePath) async {
  final source = await File(filePath).readAsString();
  return _normalizeYaml(loadYaml(source, sourceUrl: Uri.file(filePath)));
}

Object? _normalizeYaml(Object? value) => switch (value) {
  YamlMap() => <String, Object?>{
    for (final MapEntry<Object?, Object?> entry in value.entries)
      entry.key.toString(): _normalizeYaml(entry.value),
  },
  YamlList() => <Object?>[
    for (final Object? element in value) _normalizeYaml(element),
  ],
  _ => value,
};

Future<bool> fileExists(String filePath) async =>
    await FileSystemEntity.type(filePath) != FileSystemEntityType.notFound;
