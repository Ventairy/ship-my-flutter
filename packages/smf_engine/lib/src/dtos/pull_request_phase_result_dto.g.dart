// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_request_phase_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PullRequestNoopResultDto _$PullRequestNoopResultDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PullRequestNoopResultDto', json, ($checkedConvert) {
  final val = PullRequestNoopResultDto(
    $type: $checkedConvert('nextPhase', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'nextPhase'});

Map<String, dynamic> _$PullRequestNoopResultDtoToJson(
  PullRequestNoopResultDto instance,
) => <String, dynamic>{'nextPhase': instance.$type};

PullRequestReleaseCandidateResultDto
_$PullRequestReleaseCandidateResultDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PullRequestReleaseCandidateResultDto',
      json,
      ($checkedConvert) {
        final val = PullRequestReleaseCandidateResultDto(
          targets: $checkedConvert(
            'targets',
            (v) => (v as List<dynamic>)
                .map(
                  (e) => ReleaseTargetDto.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          ),
          releaseBranch: $checkedConvert('releaseBranch', (v) => v as String),
          pullRequestNumber: $checkedConvert(
            'pullRequestNumber',
            (v) => (v as num?)?.toInt(),
          ),
          $type: $checkedConvert('nextPhase', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {r'$type': 'nextPhase'},
    );

Map<String, dynamic> _$PullRequestReleaseCandidateResultDtoToJson(
  PullRequestReleaseCandidateResultDto instance,
) => <String, dynamic>{
  'targets': instance.targets.map((e) => e.toJson()).toList(),
  'releaseBranch': instance.releaseBranch,
  'pullRequestNumber': ?instance.pullRequestNumber,
  'nextPhase': instance.$type,
};

PullRequestShipResultDto _$PullRequestShipResultDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PullRequestShipResultDto', json, ($checkedConvert) {
  final val = PullRequestShipResultDto(
    targets: $checkedConvert(
      'targets',
      (v) => (v as List<dynamic>)
          .map((e) => ReleaseTargetDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    $type: $checkedConvert('nextPhase', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'nextPhase'});

Map<String, dynamic> _$PullRequestShipResultDtoToJson(
  PullRequestShipResultDto instance,
) => <String, dynamic>{
  'targets': instance.targets.map((e) => e.toJson()).toList(),
  'nextPhase': instance.$type,
};
