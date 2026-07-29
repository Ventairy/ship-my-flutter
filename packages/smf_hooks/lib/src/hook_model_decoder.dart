part of 'smf_hooks_sdk.dart';

final class _HookModelDecoder {
  const _HookModelDecoder._();

  static Map<String, Object?> optionalObject(Object? value, String path) =>
      value == null ? <String, Object?>{} : object(value, path);

  static Map<String, Object?> object(Object? value, String name) {
    if (value is! Map<Object?, Object?>) {
      throw FormatException('$name must be an object.');
    }
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw FormatException('$name must contain only string keys.');
      }
      result[key] = entry.value;
    }
    return result;
  }

  static String string(Map<String, Object?> json, String name) {
    final value = json[name];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$name must be a non-empty string.');
    }
    return value;
  }

  static String? optionalString(Map<String, Object?> json, String name) {
    final value = json[name];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$name must be a non-empty string when provided.');
    }
    return value;
  }

  static List<Object?> list(Map<String, Object?> json, String name) {
    final value = json[name];
    if (value is! List<Object?>) {
      throw FormatException('$name must be a list.');
    }
    return value;
  }
}
