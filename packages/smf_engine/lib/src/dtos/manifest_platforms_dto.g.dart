// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manifest_platforms_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ManifestPlatformsDto _$ManifestPlatformsDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ManifestPlatformsDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['ios', 'android'],
    requiredKeys: const ['ios', 'android'],
    disallowNullValues: const ['ios', 'android'],
  );
  final val = _ManifestPlatformsDto(
    ios: $checkedConvert(
      'ios',
      (v) => PlatformManifestDto.fromJson(v as Map<String, dynamic>),
    ),
    android: $checkedConvert(
      'android',
      (v) => PlatformManifestDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ManifestPlatformsDtoToJson(
  _ManifestPlatformsDto instance,
) => <String, dynamic>{
  'ios': instance.ios.toJson(),
  'android': instance.android.toJson(),
};
