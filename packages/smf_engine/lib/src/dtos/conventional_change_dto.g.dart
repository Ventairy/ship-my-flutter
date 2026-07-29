// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conventional_change_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConventionalChangeDto _$ConventionalChangeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ConventionalChangeDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'commitHash',
      'type',
      'scope',
      'description',
      'body',
      'isBreaking',
      'versionBumpType',
      'platforms',
    ],
    requiredKeys: const [
      'commitHash',
      'type',
      'scope',
      'description',
      'body',
      'isBreaking',
      'versionBumpType',
      'platforms',
    ],
    disallowNullValues: const [
      'commitHash',
      'type',
      'description',
      'isBreaking',
      'platforms',
    ],
  );
  final val = _ConventionalChangeDto(
    commitHash: $checkedConvert('commitHash', (v) => v as String),
    type: $checkedConvert('type', (v) => v as String),
    scope: $checkedConvert('scope', (v) => v as String?),
    description: $checkedConvert('description', (v) => v as String),
    body: $checkedConvert('body', (v) => v as String?),
    isBreaking: $checkedConvert('isBreaking', (v) => v as bool),
    versionBumpType: $checkedConvert(
      'versionBumpType',
      (v) => $enumDecodeNullable(_$VersionBumpTypeEnumMap, v),
    ),
    platforms: $checkedConvert(
      'platforms',
      (v) => (v as List<dynamic>)
          .map((e) => $enumDecode(_$ReleasePlatformEnumMap, e))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ConventionalChangeDtoToJson(
  _ConventionalChangeDto instance,
) => <String, dynamic>{
  'commitHash': instance.commitHash,
  'type': instance.type,
  'scope': instance.scope,
  'description': instance.description,
  'body': instance.body,
  'isBreaking': instance.isBreaking,
  'versionBumpType': _$VersionBumpTypeEnumMap[instance.versionBumpType],
  'platforms': instance.platforms
      .map((e) => _$ReleasePlatformEnumMap[e]!)
      .toList(),
};

const _$VersionBumpTypeEnumMap = {
  VersionBumpType.patch: 'patch',
  VersionBumpType.minor: 'minor',
  VersionBumpType.major: 'major',
};

const _$ReleasePlatformEnumMap = {
  ReleasePlatform.ios: 'ios',
  ReleasePlatform.android: 'android',
};
