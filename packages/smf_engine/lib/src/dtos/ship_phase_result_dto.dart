import 'package:smf_engine/src/android/dtos/android_ship_release_result_dto.dart';
import 'package:smf_engine/src/ios/dtos/apple_ship_release_result_dto.dart';

/// Platform release evidence produced by the ship phase.
final class ShipPhaseResultDto {
  /// Creates a result from the releases shipped by this invocation.
  ShipPhaseResultDto({
    this.iosRelease,
    this.androidRelease,
  });

  /// Exact iOS release shipped by this invocation, if selected.
  final AppleShipReleaseResultDto? iosRelease;

  /// Exact Android release shipped by this invocation, if selected.
  final AndroidShipReleaseResultDto? androidRelease;

  /// Encodes the ship phase result.
  Map<String, Object?> toJson() => <String, Object?>{
    'shippedReleases': <Object?>[
      if (iosRelease case final release?) release.toJson(),
      if (androidRelease case final release?) release.toJson(),
    ],
  };
}
