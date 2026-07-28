// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReleasePlan _$ReleasePlanFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_ReleasePlan',
  json,
  ($checkedConvert) {
    final val = _ReleasePlan(
      platform: $checkedConvert(
        'platform',
        (v) => $enumDecode(_$PlatformEnumMap, v),
      ),
      currentVersion: $checkedConvert('currentVersion', (v) => v as String),
      nextVersion: $checkedConvert('nextVersion', (v) => v as String),
      versionBump: $checkedConvert(
        'versionBump',
        (v) => $enumDecode(_$VersionBumpEnumMap, v),
      ),
      baseSha: $checkedConvert('baseSha', (v) => v as String),
      headSha: $checkedConvert('headSha', (v) => v as String),
      changes: $checkedConvert(
        'changes',
        (v) => (v as List<dynamic>)
            .map((e) => ConventionalChange.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$ReleasePlanToJson(_ReleasePlan instance) =>
    <String, dynamic>{
      'platform': _$PlatformEnumMap[instance.platform]!,
      'currentVersion': instance.currentVersion,
      'nextVersion': instance.nextVersion,
      'versionBump': _$VersionBumpEnumMap[instance.versionBump]!,
      'baseSha': instance.baseSha,
      'headSha': instance.headSha,
      'changes': instance.changes.map((e) => e.toJson()).toList(),
    };

const _$PlatformEnumMap = {Platform.ios: 'ios', Platform.android: 'android'};

const _$VersionBumpEnumMap = {
  VersionBump.patch: 'patch',
  VersionBump.minor: 'minor',
  VersionBump.major: 'major',
};
