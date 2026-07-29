// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_release_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GitHubReleaseDto _$GitHubReleaseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_GitHubReleaseDto',
      json,
      ($checkedConvert) {
        final val = _GitHubReleaseDto(
          htmlUrl: $checkedConvert('html_url', (v) => v as String),
          tagName: $checkedConvert('tag_name', (v) => v as String),
          targetCommitish: $checkedConvert(
            'target_commitish',
            (v) => v as String,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'htmlUrl': 'html_url',
        'tagName': 'tag_name',
        'targetCommitish': 'target_commitish',
      },
    );

Map<String, dynamic> _$GitHubReleaseDtoToJson(_GitHubReleaseDto instance) =>
    <String, dynamic>{
      'html_url': instance.htmlUrl,
      'tag_name': instance.tagName,
      'target_commitish': instance.targetCommitish,
    };
