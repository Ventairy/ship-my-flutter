// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_candidate_intent_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReleaseCandidateIntentDto _$ReleaseCandidateIntentDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ReleaseCandidateIntentDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'platform',
      'version',
      'buildNumber',
      'applicationId',
      'storeApplicationId',
      'sourceCommitHash',
      'sourceFingerprint',
      'artifactSha256',
      'preparedAt',
      'schemaVersion',
    ],
    requiredKeys: const ['schemaVersion'],
    disallowNullValues: const ['schemaVersion'],
  );
  final val = _ReleaseCandidateIntentDto(
    platform: $checkedConvert(
      'platform',
      (v) => $enumDecode(_$ReleasePlatformEnumMap, v),
    ),
    version: $checkedConvert(
      'version',
      (v) => ReleaseCandidateIntentDto._versionFromJson(v as String),
    ),
    buildNumber: $checkedConvert(
      'buildNumber',
      (v) => ReleaseCandidateIntentDto._buildNumberFromJson(v as String),
    ),
    applicationId: $checkedConvert(
      'applicationId',
      (v) => ReleaseCandidateIntentDto._applicationIdFromJson(v as String),
    ),
    storeApplicationId: $checkedConvert(
      'storeApplicationId',
      (v) => ReleaseCandidateIntentDto._storeApplicationIdFromJson(v as String),
    ),
    sourceCommitHash: $checkedConvert(
      'sourceCommitHash',
      (v) => ReleaseCandidateIntentDto._sourceCommitHashFromJson(v as String),
    ),
    sourceFingerprint: $checkedConvert(
      'sourceFingerprint',
      (v) => ReleaseCandidateIntentDto._sourceFingerprintFromJson(v as String),
    ),
    artifactSha256: $checkedConvert(
      'artifactSha256',
      (v) => ReleaseCandidateIntentDto._artifactSha256FromJson(v as String),
    ),
    preparedAt: $checkedConvert(
      'preparedAt',
      (v) => ReleaseCandidateIntentDto._preparedAtFromJson(v as String),
    ),
    schemaVersion: $checkedConvert(
      'schemaVersion',
      (v) => ReleaseCandidateIntentDto._schemaVersionFromJson(v),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReleaseCandidateIntentDtoToJson(
  _ReleaseCandidateIntentDto instance,
) => <String, dynamic>{
  'platform': _$ReleasePlatformEnumMap[instance.platform]!,
  'version': instance.version,
  'buildNumber': instance.buildNumber,
  'applicationId': instance.applicationId,
  'storeApplicationId': instance.storeApplicationId,
  'sourceCommitHash': instance.sourceCommitHash,
  'sourceFingerprint': instance.sourceFingerprint,
  'artifactSha256': instance.artifactSha256,
  'preparedAt': instance.preparedAt.toUtc().toIso8601String(),
  'schemaVersion': instance.schemaVersion,
};

const _$ReleasePlatformEnumMap = {
  ReleasePlatform.ios: 'ios',
  ReleasePlatform.android: 'android',
};
