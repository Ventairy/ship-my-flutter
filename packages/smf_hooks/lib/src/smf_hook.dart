part of 'smf_hooks_sdk.dart';

/// Base class for a typed repository hook.
///
/// Implement [run] in `smf/hooks/before_create_pr.dart` or
/// `smf/hooks/before_build.dart`, then call [runSmfHook] from `main`.
abstract class SmfHook {
  const SmfHook();

  /// Executes repository-owned preparation with a phase-specific context.
  Future<void> run(covariant SmfHookContext context);
}
