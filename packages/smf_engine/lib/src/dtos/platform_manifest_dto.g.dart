// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_manifest_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlatformManifestDto _$PlatformManifestDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PlatformManifestDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['version', 'endCommitHash', 'isReleasePending'],
        requiredKeys: const ['version', 'endCommitHash', 'isReleasePending'],
        disallowNullValues: const [
          'version',
          'endCommitHash',
          'isReleasePending',
        ],
      );
      final val = _PlatformManifestDto(
        version: $checkedConvert('version', (v) => v as String),
        endCommitHash: $checkedConvert('endCommitHash', (v) => v as String),
        isReleasePending: $checkedConvert('isReleasePending', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$PlatformManifestDtoToJson(
  _PlatformManifestDto instance,
) => <String, dynamic>{
  'version': instance.version,
  'endCommitHash': instance.endCommitHash,
  'isReleasePending': instance.isReleasePending,
};
