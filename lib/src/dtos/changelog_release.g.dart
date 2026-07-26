// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'changelog_release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChangelogRelease _$ChangelogReleaseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ChangelogRelease', json, ($checkedConvert) {
      final val = _ChangelogRelease(
        version: $checkedConvert('version', (v) => v as String),
        preparedAt: $checkedConvert(
          'preparedAt',
          (v) => const UtcDateTimeConverter().fromJson(v as String),
        ),
        baseSha: $checkedConvert('baseSha', (v) => v as String),
        headSha: $checkedConvert('headSha', (v) => v as String),
        changes: $checkedConvert(
          'changes',
          (v) => (v as List<dynamic>)
              .map(
                (e) => ConventionalChange.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ChangelogReleaseToJson(_ChangelogRelease instance) =>
    <String, dynamic>{
      'version': instance.version,
      'preparedAt': const UtcDateTimeConverter().toJson(instance.preparedAt),
      'baseSha': instance.baseSha,
      'headSha': instance.headSha,
      'changes': instance.changes.map((e) => e.toJson()).toList(),
    };
