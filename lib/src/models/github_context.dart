/// Authentication and repository identity for GitHub operations.
///
/// This deliberately does not use generated value semantics so its token is
/// never included in a generated `toString`.
final class GitHubContext {
  /// Creates a GitHub operation context.
  const GitHubContext({
    required this.owner,
    required this.repo,
    required this.token,
  });

  /// Repository owner.
  final String owner;

  /// Repository name.
  final String repo;

  /// GitHub access token. Callers must never log or persist this value.
  final String token;
}
