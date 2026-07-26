/// Flutter release automation with platform-scoped release planning.
library;

export 'src/apple/candidate.dart'
    show CandidateDependencies, CandidateOptions, createIosCandidate;
export 'src/apple/client.dart'
    show
        ApiResource,
        AppAttributes,
        AppStoreConnectApi,
        AppStoreConnectClient,
        AppStoreVersionAttributes,
        BuildAttributes,
        PrereleaseVersionAttributes;
export 'src/apple/credentials.dart'
    show
        CredentialProvider,
        appleCredentialsFromEnvironment,
        signingCredentialsFromEnvironment;
export 'src/apple/project.dart' show resolveBundleId;
export 'src/apple/promote.dart'
    show PromotionOptions, PromotionResult, promoteIosRelease;
export 'src/apple/signing.dart'
    show InstalledProfile, SigningSession, installSigningAssets;
export 'src/apple/upload.dart'
    show buildFlutterIpa, findIpa, prepareFlutterDependencies, uploadIpa;
export 'src/candidate_receipt.dart'
    show loadCandidateReceipt, validateCandidateReceipt;
export 'src/changelog.dart'
    show formatChange, releaseNotesMarkdown, releasePullRequestBody;
export 'src/cli.dart' show CliIo, runShipMyFlutterCli, shipMyFlutterVersion;
export 'src/config.dart'
    show
        loadChangelog,
        loadConfig,
        loadManifest,
        loadStoreReleaseNotes,
        validateChangelog,
        validateConfig,
        validateManifest,
        validateStoreReleaseNotes;
export 'src/conventional_commit.dart' show highestBump, parseConventionalCommit;
export 'src/error.dart' show ShipError;
export 'src/fingerprint.dart' show fileSha256, sourceFingerprint;
export 'src/git.dart'
    show
        GitCommit,
        authenticatedGit,
        commitsBetween,
        configureBotIdentity,
        currentBranch,
        currentSha,
        git,
        isClean,
        tagExists,
        tagSha;
export 'src/github.dart'
    show
        ReleasePullRequestResult,
        createOrUpdateReleasePullRequest,
        findReleasePullRequest,
        releaseBranchName;
export 'src/github_api.dart'
    show
        GitHubApi,
        GitHubApiException,
        GitHubPullRequest,
        GitHubRelease,
        GitHubRestApi;
export 'src/hooks.dart' show runBeforeReleasePrHook;
export 'src/init.dart' show InitOptions, initialize;
export 'src/manifest_files.dart' show applyReleasePlan, emptyChangelog;
export 'src/model.dart';
export 'src/orchestrator.dart' show ReleaseOrchestrator, planGitHubRelease;
export 'src/paths.dart'
    show ShipPaths, candidatePath, resolveShipPaths, shipDirectoryName;
export 'src/process_runner.dart'
    show ProcessRunner, RunOptions, RunResult, SystemProcessRunner;
export 'src/release_plan.dart'
    show ReleasePlanner, createReleasePlan, releaseNeedsPromotion, releaseTag;
export 'src/validate.dart' show validateRepository;
