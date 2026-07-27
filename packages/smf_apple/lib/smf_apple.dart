/// Apple platform delivery for SMF.
library;

export 'src/apple/candidate.dart' show createIosCandidate;
export 'src/apple/candidate_dependencies.dart' show CandidateDependencies;
export 'src/apple/candidate_options.dart' show CandidateOptions;
export 'src/apple/client.dart';
export 'src/apple/credentials.dart'
    show
        CredentialProvider,
        appleCredentialsFromEnvironment,
        signingCredentialsFromEnvironment;
export 'src/apple/dtos/promotion_result.dart' show PromotionResult;
export 'src/apple/installed_profile.dart' show InstalledProfile;
export 'src/apple/project.dart' show resolveBundleId;
export 'src/apple/promote.dart' show promoteIosRelease;
export 'src/apple/promotion_options.dart' show PromotionOptions;
export 'src/apple/signing.dart' show installSigningAssets;
export 'src/apple/signing_session.dart' show SigningSession;
export 'src/apple/upload.dart'
    show findIpa, resolveIosBuildCommand, runIosBuildCommand, uploadIpa;
export 'src/models/apple_credentials.dart' show AppleCredentials;
export 'src/models/signing_credentials.dart' show SigningCredentials;
