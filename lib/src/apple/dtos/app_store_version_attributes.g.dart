// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_store_version_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppStoreVersionAttributes _$AppStoreVersionAttributesFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_AppStoreVersionAttributes', json, ($checkedConvert) {
  final val = _AppStoreVersionAttributes(
    platform: $checkedConvert('platform', (v) => v as String),
    versionString: $checkedConvert('versionString', (v) => v as String),
    appStoreState: $checkedConvert('appStoreState', (v) => v as String),
    releaseType: $checkedConvert('releaseType', (v) => v as String),
    earliestReleaseDate: $checkedConvert(
      'earliestReleaseDate',
      (v) => v as String?,
    ),
  );
  return val;
});

Map<String, dynamic> _$AppStoreVersionAttributesToJson(
  _AppStoreVersionAttributes instance,
) => <String, dynamic>{
  'platform': instance.platform,
  'versionString': instance.versionString,
  'appStoreState': instance.appStoreState,
  'releaseType': instance.releaseType,
  'earliestReleaseDate': instance.earliestReleaseDate,
};
