/// Typed repository hooks for SMF release automation.
library;

export 'src/smf_hooks_sdk.dart'
    show
        ConventionalChange,
        PlannedReleases,
        PlatformRelease,
        SmfBeforeBuildContext,
        SmfBeforeCreatePrContext,
        SmfHook,
        SmfHookContext,
        StoreReleaseNotes,
        runSmfHook;
