/// Flutter release automation with platform-scoped release planning.
library;

export 'src/candidate_git.dart'
    show commitBeforeBuildChanges, commitCandidateReceipt;
export 'src/candidate_receipt.dart'
    show loadCandidateReceipt, validateCandidateReceipt;
export 'src/changelog.dart'
    show
        combinedReleasePullRequestBody,
        formatChange,
        releaseNotesMarkdown,
        releasePullRequestBody;
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
export 'src/conventional_commit.dart'
    show
        highestBump,
        parseConventionalCommit,
        parseConventionalCommitForPlatform;
export 'src/error.dart' show SmfError, invariant;
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
        findReleasePullRequest;
export 'src/github_api.dart'
    show
        GitHubApi,
        GitHubApiException,
        GitHubPullRequest,
        GitHubRelease,
        GitHubRestApi;
export 'src/hooks.dart' show runBeforeBuildHook, runBeforeCreatePrHook;
export 'src/init.dart' show InitOptions, initialize;
export 'src/manifest_files.dart' show applyReleasePlan, emptyChangelog;
export 'src/model.dart';
export 'src/orchestrator.dart' show ReleaseOrchestrator, planGitHubRelease;
export 'src/paths.dart'
    show
        SmfPaths,
        candidatePath,
        resolveSmfPaths,
        smfDirectoryName,
        smfPathsForApp;
export 'src/process_runner.dart'
    show
        ProcessRunner,
        RunOptions,
        RunResult,
        SystemProcessRunner,
        runShellCommand;
export 'src/release_branch.dart' show releaseBranchName;
export 'src/release_plan.dart'
    show ReleasePlanner, createReleasePlan, releaseNeedsPromotion, releaseTag;
export 'src/serialization.dart' show fileExists, readJson, writeJson;
export 'src/validate.dart' show validateRepository;
