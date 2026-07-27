import 'package:freezed_annotation/freezed_annotation.dart';

part 'testflight_config.freezed.dart';

/// TestFlight processing and tester-group configuration.
@freezed
abstract class TestflightConfig with _$TestflightConfig {
  /// Creates TestFlight configuration.
  const factory TestflightConfig({
    @Default(<String>[]) List<String> groups,
    @Default(45) int waitTimeoutMinutes,
  }) = _TestflightConfig;
}
