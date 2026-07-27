/// A bounded HTTP failure returned by GitHub.
final class GitHubApiException implements Exception {
  /// Creates a GitHub API exception.
  const GitHubApiException({
    required this.statusCode,
    required this.method,
    required this.path,
    required this.responseBody,
  });

  /// HTTP response status.
  final int statusCode;

  /// HTTP request method.
  final String method;

  /// GitHub API request path without credentials.
  final String path;

  /// Bounded response body suitable for diagnostics.
  final String responseBody;

  @override
  String toString() {
    return 'GitHub API $method $path failed with status $statusCode: '
        '$responseBody';
  }
}
