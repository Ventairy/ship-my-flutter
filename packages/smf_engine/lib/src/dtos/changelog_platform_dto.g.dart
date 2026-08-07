// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'changelog_platform_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangelogPlatformDto _$ChangelogPlatformDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ChangelogPlatformDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['releases'],
    requiredKeys: const ['releases'],
    disallowNullValues: const ['releases'],
  );
  final val = _ChangelogPlatformDto(
    releases: $checkedConvert(
      'releases',
      (v) => (v as List<dynamic>)
          .map(
            (e) => ChangelogPlatformReleaseVersionDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ChangelogPlatformDtoToJson(
  _ChangelogPlatformDto instance,
) => <String, dynamic>{
  'releases': instance.releases.map((e) => e.toJson()).toList(),
};
