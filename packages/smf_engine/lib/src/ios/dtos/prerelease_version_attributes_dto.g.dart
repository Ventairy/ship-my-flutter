// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prerelease_version_attributes_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrereleaseVersionAttributesDto _$PrereleaseVersionAttributesDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_PrereleaseVersionAttributesDto', json, ($checkedConvert) {
  final val = _PrereleaseVersionAttributesDto(
    version: $checkedConvert('version', (v) => v as String),
    platform: $checkedConvert(
      'platform',
      (v) => $enumDecode(_$ApplePlatformEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$PrereleaseVersionAttributesDtoToJson(
  _PrereleaseVersionAttributesDto instance,
) => <String, dynamic>{
  'version': instance.version,
  'platform': _$ApplePlatformEnumMap[instance.platform]!,
};

const _$ApplePlatformEnumMap = {
  ApplePlatform.ios: 'IOS',
  ApplePlatform.macOs: 'MAC_OS',
  ApplePlatform.tvOs: 'TV_OS',
  ApplePlatform.visionOs: 'VISION_OS',
};
