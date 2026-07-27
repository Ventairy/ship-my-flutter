// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_target.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReleaseTarget _$ReleaseTargetFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ReleaseTarget', json, ($checkedConvert) {
      final val = _ReleaseTarget(
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$PlatformEnumMap, v),
        ),
        version: $checkedConvert('version', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ReleaseTargetToJson(_ReleaseTarget instance) =>
    <String, dynamic>{
      'platform': _$PlatformEnumMap[instance.platform]!,
      'version': instance.version,
    };

const _$PlatformEnumMap = {Platform.ios: 'ios', Platform.android: 'android'};
