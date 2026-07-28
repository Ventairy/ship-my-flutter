// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conventional_change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConventionalChange _$ConventionalChangeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ConventionalChange', json, ($checkedConvert) {
      final val = _ConventionalChange(
        sha: $checkedConvert('sha', (v) => v as String),
        type: $checkedConvert('type', (v) => v as String),
        scope: $checkedConvert('scope', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String),
        body: $checkedConvert('body', (v) => v as String?),
        breaking: $checkedConvert('breaking', (v) => v as bool),
        versionBump: $checkedConvert(
          'versionBump',
          (v) => $enumDecodeNullable(_$VersionBumpEnumMap, v),
        ),
        platforms: $checkedConvert(
          'platforms',
          (v) => (v as List<dynamic>)
              .map((e) => $enumDecode(_$PlatformEnumMap, e))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ConventionalChangeToJson(
  _ConventionalChange instance,
) => <String, dynamic>{
  'sha': instance.sha,
  'type': instance.type,
  'scope': instance.scope,
  'description': instance.description,
  'body': instance.body,
  'breaking': instance.breaking,
  'versionBump': _$VersionBumpEnumMap[instance.versionBump],
  'platforms': instance.platforms.map((e) => _$PlatformEnumMap[e]!).toList(),
};

const _$VersionBumpEnumMap = {
  VersionBump.patch: 'patch',
  VersionBump.minor: 'minor',
  VersionBump.major: 'major',
};

const _$PlatformEnumMap = {Platform.ios: 'ios', Platform.android: 'android'};
