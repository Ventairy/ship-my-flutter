// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_intent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CandidateIntent _$CandidateIntentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CandidateIntent', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'platform',
          'version',
          'buildNumber',
          'applicationId',
          'storeApplicationId',
          'sourceSha',
          'sourceFingerprint',
          'artifactSha256',
          'preparedAt',
          'schemaVersion',
        ],
        requiredKeys: const ['schemaVersion'],
      );
      final val = _CandidateIntent(
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$PlatformEnumMap, v),
        ),
        version: $checkedConvert('version', (v) => v as String),
        buildNumber: $checkedConvert('buildNumber', (v) => v as String),
        applicationId: $checkedConvert('applicationId', (v) => v as String),
        storeApplicationId: $checkedConvert(
          'storeApplicationId',
          (v) => v as String,
        ),
        sourceSha: $checkedConvert('sourceSha', (v) => v as String),
        sourceFingerprint: $checkedConvert(
          'sourceFingerprint',
          (v) => v as String,
        ),
        artifactSha256: $checkedConvert('artifactSha256', (v) => v as String),
        preparedAt: $checkedConvert(
          'preparedAt',
          (v) => DateTime.parse(v as String),
        ),
        schemaVersion: $checkedConvert(
          'schemaVersion',
          (v) => (v as num?)?.toInt() ?? 1,
        ),
      );
      return val;
    });

Map<String, dynamic> _$CandidateIntentToJson(_CandidateIntent instance) =>
    <String, dynamic>{
      'platform': _$PlatformEnumMap[instance.platform]!,
      'version': instance.version,
      'buildNumber': instance.buildNumber,
      'applicationId': instance.applicationId,
      'storeApplicationId': instance.storeApplicationId,
      'sourceSha': instance.sourceSha,
      'sourceFingerprint': instance.sourceFingerprint,
      'artifactSha256': instance.artifactSha256,
      'preparedAt': instance.preparedAt.toUtc().toIso8601String(),
      'schemaVersion': instance.schemaVersion,
    };

const _$PlatformEnumMap = {Platform.ios: 'ios', Platform.android: 'android'};
