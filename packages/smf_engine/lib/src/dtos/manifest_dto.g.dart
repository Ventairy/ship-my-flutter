// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manifest_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ManifestDto _$ManifestDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ManifestDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['platforms', 'schemaVersion'],
        requiredKeys: const ['platforms', 'schemaVersion'],
        disallowNullValues: const ['platforms', 'schemaVersion'],
      );
      final val = _ManifestDto(
        platforms: $checkedConvert(
          'platforms',
          (v) => ManifestPlatformsDto.fromJson(v as Map<String, dynamic>),
        ),
        schemaVersion: $checkedConvert(
          'schemaVersion',
          (v) => ManifestDto._schemaVersionFromJson(v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ManifestDtoToJson(_ManifestDto instance) =>
    <String, dynamic>{
      'platforms': instance.platforms.toJson(),
      'schemaVersion': instance.schemaVersion,
    };
