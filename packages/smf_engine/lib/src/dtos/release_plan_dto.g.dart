// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_plan_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReleasePlanDto _$ReleasePlanDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ReleasePlanDto', json, ($checkedConvert) {
      final val = _ReleasePlanDto(
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$ReleasePlatformEnumMap, v),
        ),
        currentVersion: $checkedConvert('currentVersion', (v) => v as String),
        nextVersion: $checkedConvert('nextVersion', (v) => v as String),
        versionBumpType: $checkedConvert(
          'versionBumpType',
          (v) => $enumDecode(_$VersionBumpTypeEnumMap, v),
        ),
        baseCommitHash: $checkedConvert('baseCommitHash', (v) => v as String),
        endCommitHash: $checkedConvert('endCommitHash', (v) => v as String),
        changes: $checkedConvert(
          'changes',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    ConventionalChangeDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReleasePlanDtoToJson(_ReleasePlanDto instance) =>
    <String, dynamic>{
      'platform': _$ReleasePlatformEnumMap[instance.platform]!,
      'currentVersion': instance.currentVersion,
      'nextVersion': instance.nextVersion,
      'versionBumpType': _$VersionBumpTypeEnumMap[instance.versionBumpType]!,
      'baseCommitHash': instance.baseCommitHash,
      'endCommitHash': instance.endCommitHash,
      'changes': instance.changes.map((e) => e.toJson()).toList(),
    };

const _$ReleasePlatformEnumMap = {
  ReleasePlatform.ios: 'ios',
  ReleasePlatform.android: 'android',
};

const _$VersionBumpTypeEnumMap = {
  VersionBumpType.patch: 'patch',
  VersionBumpType.minor: 'minor',
  VersionBumpType.major: 'major',
};
