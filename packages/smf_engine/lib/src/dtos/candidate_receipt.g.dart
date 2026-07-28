// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CandidateReceipt _$CandidateReceiptFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CandidateReceipt', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'platform',
          'version',
          'buildNumber',
          'artifactId',
          'applicationId',
          'storeApplicationId',
          'sourceSha',
          'sourceFingerprint',
          'artifactSha256',
          'uploadedAt',
          'testingDestinations',
          'processingState',
          'schemaVersion',
        ],
        requiredKeys: const ['schemaVersion'],
      );
      final val = _CandidateReceipt(
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecode(_$PlatformEnumMap, v),
        ),
        version: $checkedConvert('version', (v) => v as String),
        buildNumber: $checkedConvert('buildNumber', (v) => v as String),
        artifactId: $checkedConvert('artifactId', (v) => v as String),
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
        uploadedAt: $checkedConvert(
          'uploadedAt',
          (v) => const UtcDateTimeConverter().fromJson(v as String),
        ),
        testingDestinations: $checkedConvert(
          'testingDestinations',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        processingState: $checkedConvert(
          'processingState',
          (v) => v as String? ?? 'VALID',
        ),
        schemaVersion: $checkedConvert(
          'schemaVersion',
          (v) => (v as num?)?.toInt() ?? 2,
        ),
      );
      return val;
    });

Map<String, dynamic> _$CandidateReceiptToJson(_CandidateReceipt instance) =>
    <String, dynamic>{
      'platform': _$PlatformEnumMap[instance.platform]!,
      'version': instance.version,
      'buildNumber': instance.buildNumber,
      'artifactId': instance.artifactId,
      'applicationId': instance.applicationId,
      'storeApplicationId': instance.storeApplicationId,
      'sourceSha': instance.sourceSha,
      'sourceFingerprint': instance.sourceFingerprint,
      'artifactSha256': instance.artifactSha256,
      'uploadedAt': const UtcDateTimeConverter().toJson(instance.uploadedAt),
      'testingDestinations': instance.testingDestinations,
      'processingState': instance.processingState,
      'schemaVersion': instance.schemaVersion,
    };

const _$PlatformEnumMap = {Platform.ios: 'ios', Platform.android: 'android'};
