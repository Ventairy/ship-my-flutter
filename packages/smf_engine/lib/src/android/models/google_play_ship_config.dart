import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/android/enums/google_play_ship_target.dart';

part 'google_play_ship_config.freezed.dart';

/// Google Play delivery performed after the release candidate is approved and merged.
@freezed
abstract class GooglePlayShipConfig with _$GooglePlayShipConfig {
  /// Creates Google Play ship configuration.
  const factory GooglePlayShipConfig({
    required GooglePlayShipTarget target,
    @Default(<String>[]) List<String> tracks,
  }) = _GooglePlayShipConfig;
}
