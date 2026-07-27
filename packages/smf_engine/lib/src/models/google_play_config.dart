import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/models/release_enums.dart';

part 'google_play_config.freezed.dart';

/// Google Play testing and production delivery configuration.
@freezed
abstract class GooglePlayConfig with _$GooglePlayConfig {
  /// Creates Google Play configuration.
  const factory GooglePlayConfig({
    @Default('internal') String testingTrack,
    @Default('production') String productionTrack,
    @Default(ReleaseMode.upload) ReleaseMode mode,
  }) = _GooglePlayConfig;
}
