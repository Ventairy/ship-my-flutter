/// Android app-bundle and Google Play delivery for SMF.
library;

export 'src/android/build.dart'
    show
        findAab,
        resolveAndroidBuildCommand,
        runAndroidBuildCommand,
        signAabUploadKey,
        verifyAabUploadKey;
export 'src/android/candidate.dart'
    show
        AndroidCandidateDependencies,
        AndroidCandidateOptions,
        createAndroidCandidate;
export 'src/android/client.dart'
    show
        GooglePlayApi,
        GooglePlayBundle,
        GooglePlayClient,
        GooglePlayEdit,
        GooglePlayRelease,
        GooglePlayTrack;
export 'src/android/credentials.dart'
    show
        AndroidCredentialProvider,
        androidSigningCredentialsFromEnvironment,
        googlePlayCredentialsFromEnvironment;
export 'src/android/project.dart' show ResolvePackageName, resolvePackageName;
export 'src/android/promote.dart'
    show AndroidPromotionOptions, AndroidPromotionResult, promoteAndroidRelease;
export 'src/android/signing.dart'
    show AndroidSigningSession, installAndroidSigning;
export 'src/models/android_signing_credentials.dart';
export 'src/models/google_play_credentials.dart';
