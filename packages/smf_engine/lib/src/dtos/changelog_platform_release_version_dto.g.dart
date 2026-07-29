// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'changelog_platform_release_version_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangelogPlatformReleaseVersionDto
_$ChangelogPlatformReleaseVersionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ChangelogPlatformReleaseVersionDto', json, (
      $checkedConvert,
    ) {
      $checkKeys(
        json,
        allowedKeys: const [
          'version',
          'preparedAt',
          'baseCommitHash',
          'endCommitHash',
          'changes',
        ],
        requiredKeys: const [
          'version',
          'preparedAt',
          'baseCommitHash',
          'endCommitHash',
          'changes',
        ],
        disallowNullValues: const [
          'version',
          'preparedAt',
          'baseCommitHash',
          'endCommitHash',
          'changes',
        ],
      );
      final val = _ChangelogPlatformReleaseVersionDto(
        version: $checkedConvert('version', (v) => v as String),
        preparedAt: $checkedConvert(
          'preparedAt',
          (v) => DateTime.parse(v as String),
        ),
        baseCommitHash: $checkedConvert('baseCommitHash', (v) => v as String),
        endCommitHash: $checkedConvert('endCommitHash', (v) => v as String),
        changes: $checkedConvert(
          'changes',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    ConventionalChangeDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ChangelogPlatformReleaseVersionDtoToJson(
  _ChangelogPlatformReleaseVersionDto instance,
) => <String, dynamic>{
  'version': instance.version,
  'preparedAt': instance.preparedAt.toUtc().toIso8601String(),
  'baseCommitHash': instance.baseCommitHash,
  'endCommitHash': instance.endCommitHash,
  'changes': instance.changes.map((e) => e.toJson()).toList(),
};
