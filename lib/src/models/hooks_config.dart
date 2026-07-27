import 'package:freezed_annotation/freezed_annotation.dart';

import 'hook_config.dart';

part 'hooks_config.freezed.dart';

/// Repository-owned lifecycle hooks.
@freezed
abstract class HooksConfig with _$HooksConfig {
  /// Creates hook configuration.
  const factory HooksConfig({
    HookConfig? beforeCreatePr,
    HookConfig? beforeBuild,
  }) = _HooksConfig;
}
