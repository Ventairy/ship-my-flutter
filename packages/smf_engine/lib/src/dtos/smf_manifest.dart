import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smf_engine/src/dtos/platform_manifest.dart';
import 'package:smf_engine/src/models/release_enums.dart';

part 'smf_manifest.freezed.dart';

/// Version state persisted for every enabled release platform.
@freezed
abstract class SmfManifest with _$SmfManifest {
  /// Creates the repository release manifest.
  const factory SmfManifest({
    required PlatformManifest ios,
    @Default(1) int schemaVersion,
  }) = _SmfManifest;

  const SmfManifest._();

  /// Returns release state for [platform].
  PlatformManifest forPlatform(Platform platform) => switch (platform) {
    Platform.ios => ios,
  };

  /// Encodes the stable manifest wire format.
  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'platforms': <String, Object?>{'ios': ios.toJson()},
  };
}
