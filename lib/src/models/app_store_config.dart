import 'package:freezed_annotation/freezed_annotation.dart';

import 'release_enums.dart';

part 'app_store_config.freezed.dart';

/// App Store promotion and post-approval release configuration.
@freezed
abstract class AppStoreConfig with _$AppStoreConfig {
  /// Creates App Store configuration.
  const factory AppStoreConfig({
    @Default(ReleaseMode.uploadOnly) ReleaseMode mode,
  }) = _AppStoreConfig;
}
