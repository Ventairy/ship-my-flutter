import 'package:freezed_annotation/freezed_annotation.dart';

part 'hooks_config.freezed.dart';

/// Repository-owned lifecycle hooks.
@freezed
abstract class HooksConfig with _$HooksConfig {
  /// Creates hook configuration.
  const factory HooksConfig({
    String? beforeReleasePr,
    String? beforeCandidate,
  }) = _HooksConfig;
}
