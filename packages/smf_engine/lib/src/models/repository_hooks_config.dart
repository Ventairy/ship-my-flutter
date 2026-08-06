import 'package:freezed_annotation/freezed_annotation.dart';

part 'repository_hooks_config.freezed.dart';

/// Secret environment names explicitly made available to repository hooks.
@freezed
abstract class RepositoryHooksConfig with _$RepositoryHooksConfig {
  /// Creates repository hook configuration.
  const factory RepositoryHooksConfig({
    @Default(<String>[]) List<String> beforeCreatePullRequestSecrets,
    @Default(<String>[]) List<String> beforeBuildSecrets,
  }) = _RepositoryHooksConfig;
}
