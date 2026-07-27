import 'package:freezed_annotation/freezed_annotation.dart';

part 'hook_config.freezed.dart';

/// One repository-owned lifecycle hook.
@freezed
abstract class HookConfig with _$HookConfig {
  /// Creates hook configuration.
  const factory HookConfig({required String run, @Default(true) bool commit}) =
      _HookConfig;
}
