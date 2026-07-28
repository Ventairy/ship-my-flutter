import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_manifest.freezed.dart';
part 'platform_manifest.g.dart';

/// Version and release progress persisted for one platform.
@freezed
abstract class PlatformManifest with _$PlatformManifest {
  /// Creates platform release state.
  @JsonSerializable(checked: true)
  const factory PlatformManifest({
    required String version,
    required String baselineSha,
    required bool pendingRelease,
  }) = _PlatformManifest;

  /// Decodes typed platform state without repository-domain validation.
  ///
  /// Use `SmfState.parseManifest` when reading repository state.
  factory PlatformManifest.fromJson(Map<String, Object?> json) => _$PlatformManifestFromJson(json);
}
