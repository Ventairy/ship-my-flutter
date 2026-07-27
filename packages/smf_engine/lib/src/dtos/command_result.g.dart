// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommandResult _$CommandResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CommandResult', json, ($checkedConvert) {
      final val = _CommandResult(
        phase: $checkedConvert('phase', (v) => v as String),
        releases: $checkedConvert(
          'releases',
          (v) => (v as List<dynamic>?)
              ?.map((e) => ReleaseTarget.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
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
      'releases': ?instance.releases?.map((e) => e.toJson()).toList(),
      'branch': ?instance.branch,
      'pullRequestNumber': ?instance.pullRequestNumber,
    };
