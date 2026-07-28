// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_attributes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BuildAttributes _$BuildAttributesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_BuildAttributes', json, ($checkedConvert) {
      final val = _BuildAttributes(
        version: $checkedConvert('version', (v) => v as String),
        processingState: $checkedConvert(
          'processingState',
          (v) => $enumDecode(_$BuildProcessingStateEnumMap, v),
        ),
        uploadedDate: $checkedConvert('uploadedDate', (v) => v as String?),
        expired: $checkedConvert('expired', (v) => v as bool? ?? false),
        usesNonExemptEncryption: $checkedConvert(
          'usesNonExemptEncryption',
          (v) => v as bool?,
        ),
      );
      return val;
    });

Map<String, dynamic> _$BuildAttributesToJson(
  _BuildAttributes instance,
) => <String, dynamic>{
  'version': instance.version,
  'processingState': _$BuildProcessingStateEnumMap[instance.processingState]!,
  'uploadedDate': instance.uploadedDate,
  'expired': instance.expired,
  'usesNonExemptEncryption': instance.usesNonExemptEncryption,
};

const _$BuildProcessingStateEnumMap = {
  BuildProcessingState.processing: 'PROCESSING',
  BuildProcessingState.failed: 'FAILED',
  BuildProcessingState.invalid: 'INVALID',
  BuildProcessingState.valid: 'VALID',
};
