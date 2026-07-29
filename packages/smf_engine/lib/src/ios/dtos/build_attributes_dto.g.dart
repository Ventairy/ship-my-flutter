// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_attributes_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BuildAttributesDto _$BuildAttributesDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_BuildAttributesDto',
      json,
      ($checkedConvert) {
        final val = _BuildAttributesDto(
          version: $checkedConvert('version', (v) => v as String),
          processingState: $checkedConvert(
            'processingState',
            (v) => $enumDecode(_$BuildProcessingStateEnumMap, v),
          ),
          uploadedDate: $checkedConvert('uploadedDate', (v) => v as String?),
          isExpired: $checkedConvert('expired', (v) => v as bool? ?? false),
          doesUseNonExemptEncryption: $checkedConvert(
            'usesNonExemptEncryption',
            (v) => v as bool?,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'isExpired': 'expired',
        'doesUseNonExemptEncryption': 'usesNonExemptEncryption',
      },
    );

Map<String, dynamic> _$BuildAttributesDtoToJson(
  _BuildAttributesDto instance,
) => <String, dynamic>{
  'version': instance.version,
  'processingState': _$BuildProcessingStateEnumMap[instance.processingState]!,
  'uploadedDate': instance.uploadedDate,
  'expired': instance.isExpired,
  'usesNonExemptEncryption': instance.doesUseNonExemptEncryption,
};

const _$BuildProcessingStateEnumMap = {
  BuildProcessingState.processing: 'PROCESSING',
  BuildProcessingState.failed: 'FAILED',
  BuildProcessingState.invalid: 'INVALID',
  BuildProcessingState.valid: 'VALID',
};
