// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prerelease_version_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrereleaseVersionAttributes _$PrereleaseVersionAttributesFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_PrereleaseVersionAttributes', json, ($checkedConvert) {
  final val = _PrereleaseVersionAttributes(
    version: $checkedConvert('version', (v) => v as String),
    platform: $checkedConvert(
      'platform',
      (v) => $enumDecode(_$ApplePlatformEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$PrereleaseVersionAttributesToJson(
  _PrereleaseVersionAttributes instance,
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
