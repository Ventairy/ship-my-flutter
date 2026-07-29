part of 'smf_hooks_sdk.dart';

/// Context supplied before SMF creates or updates a release pull request.
final class SmfBeforeCreatePrContext extends SmfHookContext {
  const SmfBeforeCreatePrContext._({required this.release}) : super._();

  /// Nullable iOS and Android plans entering the shared release pull request.
  final PlannedReleases release;
}
