// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_pull_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GitHubPullRequest _$GitHubPullRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_GitHubPullRequest', json, ($checkedConvert) {
      final val = _GitHubPullRequest(
        number: $checkedConvert('number', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$GitHubPullRequestToJson(_GitHubPullRequest instance) =>
    <String, dynamic>{'number': instance.number};
