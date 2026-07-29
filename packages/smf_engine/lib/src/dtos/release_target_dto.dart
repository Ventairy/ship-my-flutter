import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/enums/release_platform.dart';

part 'release_target_dto.freezed.dart';
part 'release_target_dto.g.dart';

/// A platform release routed to a workflow phase.
@freezed
abstract class ReleaseTargetDto with _$ReleaseTargetDto {
  /// Creates a platform release target.
  @JsonSerializable(checked: true)
  const factory ReleaseTargetDto({
    required ReleasePlatform platform,
    required String version,
  }) = _ReleaseTargetDto;

  /// Decodes a release target from JSON.
  factory ReleaseTargetDto.fromJson(Map<String, Object?> json) => _$ReleaseTargetDtoFromJson(json);
}
