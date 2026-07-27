// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GitHubRelease _$GitHubReleaseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_GitHubRelease', json, ($checkedConvert) {
      final val = _GitHubRelease(
        htmlUrl: $checkedConvert('html_url', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'htmlUrl': 'html_url'});

Map<String, dynamic> _$GitHubReleaseToJson(_GitHubRelease instance) =>
    <String, dynamic>{'html_url': instance.htmlUrl};
