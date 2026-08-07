part of 'smf_hooks_sdk.dart';

/// Typed context shared by every repository hook.
sealed class SmfHookContext {
  const SmfHookContext._({required this.secrets});

  /// Phase-configured secrets keyed by their names from `smf/config.yaml`.
  ///
  /// The map contains no ambient or SMF-owned credentials and cannot be
  /// modified by the hook.
  final Map<String, String> secrets;
}
