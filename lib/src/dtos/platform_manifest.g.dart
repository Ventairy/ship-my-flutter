// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_manifest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlatformManifest _$PlatformManifestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_PlatformManifest', json, ($checkedConvert) {
      final val = _PlatformManifest(
        version: $checkedConvert('version', (v) => v as String),
        baselineSha: $checkedConvert('baselineSha', (v) => v as String),
        pendingRelease: $checkedConvert('pendingRelease', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$PlatformManifestToJson(_PlatformManifest instance) =>
    <String, dynamic>{
      'version': instance.version,
      'baselineSha': instance.baselineSha,
      'pendingRelease': instance.pendingRelease,
    };
