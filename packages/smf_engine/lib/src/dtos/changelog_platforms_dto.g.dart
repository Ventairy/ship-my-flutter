// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'changelog_platforms_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangelogPlatformsDto _$ChangelogPlatformsDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ChangelogPlatformsDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['ios', 'android'],
    requiredKeys: const ['ios', 'android'],
    disallowNullValues: const ['ios', 'android'],
  );
  final val = _ChangelogPlatformsDto(
    ios: $checkedConvert(
      'ios',
      (v) => ChangelogPlatformDto.fromJson(v as Map<String, dynamic>),
    ),
    android: $checkedConvert(
      'android',
      (v) => ChangelogPlatformDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ChangelogPlatformsDtoToJson(
  _ChangelogPlatformsDto instance,
) => <String, dynamic>{
  'ios': instance.ios.toJson(),
  'android': instance.android.toJson(),
};
