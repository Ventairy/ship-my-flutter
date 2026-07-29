// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apple_ship_release_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppleShipReleaseResultDto _$AppleShipReleaseResultDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_AppleShipReleaseResultDto', json, ($checkedConvert) {
  final val = _AppleShipReleaseResultDto(
    version: $checkedConvert('version', (v) => v as String),
    tag: $checkedConvert('tag', (v) => v as String),
    artifactId: $checkedConvert('artifactId', (v) => v as String),
    buildNumber: $checkedConvert('buildNumber', (v) => v as String),
    githubReleaseUrl: $checkedConvert('githubReleaseUrl', (v) => v as String),
    platform: $checkedConvert(
      'platform',
      (v) =>
          $enumDecodeNullable(_$ReleasePlatformEnumMap, v) ??
          ReleasePlatform.ios,
    ),
    appStoreVersionId: $checkedConvert(
      'appStoreVersionId',
      (v) => v as String?,
    ),
    reviewSubmissionId: $checkedConvert(
      'reviewSubmissionId',
      (v) => v as String?,
    ),
    betaReviewSubmissionId: $checkedConvert(
      'betaReviewSubmissionId',
      (v) => v as String?,
    ),
  );
  return val;
});

Map<String, dynamic> _$AppleShipReleaseResultDtoToJson(
  _AppleShipReleaseResultDto instance,
) => <String, dynamic>{
  'version': instance.version,
  'tag': instance.tag,
  'artifactId': instance.artifactId,
  'buildNumber': instance.buildNumber,
  'githubReleaseUrl': instance.githubReleaseUrl,
  'platform': _$ReleasePlatformEnumMap[instance.platform]!,
  'appStoreVersionId': ?instance.appStoreVersionId,
  'reviewSubmissionId': ?instance.reviewSubmissionId,
  'betaReviewSubmissionId': ?instance.betaReviewSubmissionId,
};

const _$ReleasePlatformEnumMap = {
  ReleasePlatform.ios: 'ios',
  ReleasePlatform.android: 'android',
};
