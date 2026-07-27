import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/release_enums.dart';
import 'platform_manifest.dart';

part 'smf_manifest.freezed.dart';

/// Version state persisted for every enabled release platform.
@freezed
abstract class SmfManifest with _$SmfManifest {
  /// Creates the repository release manifest.
  const factory SmfManifest({
    @Default(1) int schemaVersion,
    required PlatformManifest ios,
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
