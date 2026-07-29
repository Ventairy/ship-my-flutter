import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:smf_engine/src/android/models/google_play_config.dart';

part 'android_config.freezed.dart';

/// Android project, app-bundle, and Google Play configuration.
@freezed
abstract class AndroidConfig with _$AndroidConfig {
  /// Creates Android configuration.
  const factory AndroidConfig({
    @Default(false) bool isEnabled,
    @Default('0.0.0') String initialVersion,
    String? packageName,
    String? buildCommand,
    @Default('build/app/outputs/bundle/release') String aabOutputPath,
    @Default(GooglePlayConfig()) GooglePlayConfig googlePlay,
  }) = _AndroidConfig;
}
