import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/release_enums.dart';
import 'platform_manifest.dart';

part 'ship_manifest.freezed.dart';

/// Version state persisted for every enabled release platform.
@freezed
abstract class ShipManifest with _$ShipManifest {
  /// Creates the repository release manifest.
  const factory ShipManifest({
    @Default(1) int schemaVersion,
    required PlatformManifest ios,
  }) = _ShipManifest;

  const ShipManifest._();

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
