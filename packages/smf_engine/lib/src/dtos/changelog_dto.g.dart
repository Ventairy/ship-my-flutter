// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'changelog_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangelogDto _$ChangelogDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ChangelogDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['platforms', 'schemaVersion'],
        requiredKeys: const ['platforms', 'schemaVersion'],
        disallowNullValues: const ['platforms', 'schemaVersion'],
      );
      final val = _ChangelogDto(
        platforms: $checkedConvert(
          'platforms',
          (v) => ChangelogPlatformsDto.fromJson(v as Map<String, dynamic>),
        ),
        schemaVersion: $checkedConvert(
          'schemaVersion',
          (v) => ChangelogDto._schemaVersionFromJson(v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ChangelogDtoToJson(_ChangelogDto instance) =>
    <String, dynamic>{
      'platforms': instance.platforms.toJson(),
      'schemaVersion': instance.schemaVersion,
    };
