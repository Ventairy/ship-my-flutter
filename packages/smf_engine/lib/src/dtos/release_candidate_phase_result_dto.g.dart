// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_candidate_phase_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReleaseCandidatePhaseResultDto _$ReleaseCandidatePhaseResultDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ReleaseCandidatePhaseResultDto', json, ($checkedConvert) {
  final val = _ReleaseCandidatePhaseResultDto(
    releaseCandidateReceipts: $checkedConvert(
      'releaseCandidateReceipts',
      (v) => (v as List<dynamic>)
          .map(
            (e) =>
                ReleaseCandidateReceiptDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReleaseCandidatePhaseResultDtoToJson(
  _ReleaseCandidatePhaseResultDto instance,
) => <String, dynamic>{
  'releaseCandidateReceipts': instance.releaseCandidateReceipts
      .map((e) => e.toJson())
      .toList(),
};
