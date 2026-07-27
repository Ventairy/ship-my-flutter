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
        buildId: $checkedConvert('buildId', (v) => v as String),
        appStoreVersionId: $checkedConvert(
          'appStoreVersionId',
          (v) => v as String?,
        ),
        reviewSubmissionId: $checkedConvert(
          'reviewSubmissionId',
          (v) => v as String?,
        ),
        githubReleaseUrl: $checkedConvert(
          'githubReleaseUrl',
          (v) => v as String,
        ),
      );
      return val;
    });

Map<String, dynamic> _$PromotionResultToJson(_PromotionResult instance) =>
    <String, dynamic>{
      'version': instance.version,
      'tag': instance.tag,
      'buildId': instance.buildId,
      'appStoreVersionId': ?instance.appStoreVersionId,
      'reviewSubmissionId': ?instance.reviewSubmissionId,
      'githubReleaseUrl': instance.githubReleaseUrl,
    };
