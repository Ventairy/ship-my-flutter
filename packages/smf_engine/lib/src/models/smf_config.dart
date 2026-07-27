import 'package:freezed_annotation/freezed_annotation.dart';

import 'ios_config.dart';

part 'smf_config.freezed.dart';

/// Validated SMF application configuration.
@freezed
abstract class SmfConfig with _$SmfConfig {
  /// Creates application configuration.
  const factory SmfConfig({
    @Default(1) int schemaVersion,
    String? flavor,
    @Default('main') String targetBranch,
    required IosConfig ios,
  }) = _SmfConfig;
}
