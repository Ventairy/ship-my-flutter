part of 'smf_hooks_sdk.dart';

/// Loads SMF's private protocol, runs [hook], and confirms completion.
Future<void> runSmfHook(SmfHook hook) => _SmfHookRunner(Platform.environment).execute(hook);
