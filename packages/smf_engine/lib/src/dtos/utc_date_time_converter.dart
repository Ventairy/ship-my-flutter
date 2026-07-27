import 'package:json_annotation/json_annotation.dart';

/// Serializes date-times as normalized UTC ISO-8601 strings.
final class UtcDateTimeConverter implements JsonConverter<DateTime, String> {
  /// Creates the converter.
  const UtcDateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json).toUtc();

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}
