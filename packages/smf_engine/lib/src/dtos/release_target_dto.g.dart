// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_target_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReleaseTargetDto _$ReleaseTargetDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ReleaseTargetDto', json, ($checkedConvert) {
      final val = _ReleaseTargetDto(
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$ReleasePlatformEnumMap, v),
        ),
        version: $checkedConvert('version', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ReleaseTargetDtoToJson(_ReleaseTargetDto instance) =>
    <String, dynamic>{
      'platform': _$ReleasePlatformEnumMap[instance.platform]!,
      'version': instance.version,
    };

const _$ReleasePlatformEnumMap = {
  ReleasePlatform.ios: 'ios',
  ReleasePlatform.android: 'android',
};
