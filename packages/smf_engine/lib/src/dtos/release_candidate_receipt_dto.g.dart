// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_candidate_receipt_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReleaseCandidateReceiptDto _$ReleaseCandidateReceiptDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ReleaseCandidateReceiptDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'platform',
      'version',
      'buildNumber',
      'artifactId',
      'applicationId',
      'storeApplicationId',
      'sourceCommitHash',
      'sourceFingerprint',
      'artifactSha256',
      'uploadedAt',
      'testingDestinations',
      'processingState',
      'schemaVersion',
    ],
    requiredKeys: const ['processingState', 'schemaVersion'],
    disallowNullValues: const ['processingState', 'schemaVersion'],
  );
  final val = _ReleaseCandidateReceiptDto(
    platform: $checkedConvert(
      'platform',
      (v) => $enumDecode(_$ReleasePlatformEnumMap, v),
    ),
    version: $checkedConvert(
      'version',
      (v) => ReleaseCandidateReceiptDto._versionFromJson(v as String),
    ),
    buildNumber: $checkedConvert(
      'buildNumber',
      (v) => ReleaseCandidateReceiptDto._buildNumberFromJson(v as String),
    ),
    artifactId: $checkedConvert(
      'artifactId',
      (v) => ReleaseCandidateReceiptDto._artifactIdFromJson(v as String),
    ),
    applicationId: $checkedConvert(
      'applicationId',
      (v) => ReleaseCandidateReceiptDto._applicationIdFromJson(v as String),
    ),
    storeApplicationId: $checkedConvert(
      'storeApplicationId',
      (v) =>
          ReleaseCandidateReceiptDto._storeApplicationIdFromJson(v as String),
    ),
    sourceCommitHash: $checkedConvert(
      'sourceCommitHash',
      (v) => ReleaseCandidateReceiptDto._sourceCommitHashFromJson(v as String),
    ),
    sourceFingerprint: $checkedConvert(
      'sourceFingerprint',
      (v) => ReleaseCandidateReceiptDto._sourceFingerprintFromJson(v as String),
    ),
    artifactSha256: $checkedConvert(
      'artifactSha256',
      (v) => ReleaseCandidateReceiptDto._artifactSha256FromJson(v as String),
    ),
    uploadedAt: $checkedConvert(
      'uploadedAt',
      (v) => ReleaseCandidateReceiptDto._uploadedAtFromJson(v as String),
    ),
    testingDestinations: $checkedConvert(
      'testingDestinations',
      (v) => ReleaseCandidateReceiptDto._testingDestinationsFromJson(v as List),
    ),
    processingState: $checkedConvert(
      'processingState',
      (v) => ReleaseCandidateReceiptDto._processingStateFromJson(v as String),
    ),
    schemaVersion: $checkedConvert(
      'schemaVersion',
      (v) => ReleaseCandidateReceiptDto._schemaVersionFromJson(v),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReleaseCandidateReceiptDtoToJson(
  _ReleaseCandidateReceiptDto instance,
) => <String, dynamic>{
  'platform': _$ReleasePlatformEnumMap[instance.platform]!,
  'version': instance.version,
  'buildNumber': instance.buildNumber,
  'artifactId': instance.artifactId,
  'applicationId': instance.applicationId,
  'storeApplicationId': instance.storeApplicationId,
  'sourceCommitHash': instance.sourceCommitHash,
  'sourceFingerprint': instance.sourceFingerprint,
  'artifactSha256': instance.artifactSha256,
  'uploadedAt': instance.uploadedAt.toUtc().toIso8601String(),
  'testingDestinations': instance.testingDestinations,
  'processingState': instance.processingState,
  'schemaVersion': instance.schemaVersion,
};

const _$ReleasePlatformEnumMap = {
  ReleasePlatform.ios: 'ios',
  ReleasePlatform.android: 'android',
};
