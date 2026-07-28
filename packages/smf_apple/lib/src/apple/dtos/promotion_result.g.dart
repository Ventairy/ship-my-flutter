// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PromotionResult _$PromotionResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PromotionResult', json, ($checkedConvert) {
      final val = _PromotionResult(
        version: $checkedConvert('version', (v) => v as String),
        tag: $checkedConvert('tag', (v) => v as String),
        artifactId: $checkedConvert('artifactId', (v) => v as String),
        buildNumber: $checkedConvert('buildNumber', (v) => v as String),
        githubReleaseUrl: $checkedConvert(
          'githubReleaseUrl',
          (v) => v as String,
        ),
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecodeNullable(_$PlatformEnumMap, v) ?? Platform.ios,
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

Map<String, dynamic> _$PromotionResultToJson(_PromotionResult instance) =>
    <String, dynamic>{
      'version': instance.version,
      'tag': instance.tag,
      'artifactId': instance.artifactId,
      'buildNumber': instance.buildNumber,
      'githubReleaseUrl': instance.githubReleaseUrl,
      'platform': _$PlatformEnumMap[instance.platform]!,
      'appStoreVersionId': ?instance.appStoreVersionId,
      'reviewSubmissionId': ?instance.reviewSubmissionId,
      'betaReviewSubmissionId': ?instance.betaReviewSubmissionId,
    };

const _$PlatformEnumMap = {Platform.ios: 'ios', Platform.android: 'android'};
