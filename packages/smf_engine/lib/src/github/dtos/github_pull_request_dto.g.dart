// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_pull_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GitHubPullRequestDto _$GitHubPullRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_GitHubPullRequestDto', json, ($checkedConvert) {
  final val = _GitHubPullRequestDto(
    number: $checkedConvert('number', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$GitHubPullRequestDtoToJson(
  _GitHubPullRequestDto instance,
) => <String, dynamic>{'number': instance.number};
