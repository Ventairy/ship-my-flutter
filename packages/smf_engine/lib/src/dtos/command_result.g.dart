// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommandResult _$CommandResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CommandResult', json, ($checkedConvert) {
      final val = _CommandResult(
        phase: $checkedConvert('phase', (v) => v as String),
        platform: $checkedConvert(
          'platform',
          (v) => $enumDecodeNullable(_$PlatformEnumMap, v),
        ),
        version: $checkedConvert('version', (v) => v as String?),
        branch: $checkedConvert('branch', (v) => v as String?),
        pullRequestNumber: $checkedConvert(
          'pullRequestNumber',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CommandResultToJson(_CommandResult instance) =>
    <String, dynamic>{
      'phase': instance.phase,
      'platform': ?_$PlatformEnumMap[instance.platform],
      'version': ?instance.version,
      'branch': ?instance.branch,
      'pullRequestNumber': ?instance.pullRequestNumber,
    };

const _$PlatformEnumMap = {Platform.ios: 'ios'};
