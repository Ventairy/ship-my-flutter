import 'dart:convert';

import 'package:http/http.dart' as http;

import 'error.dart';
import 'model.dart';

final class GitHubPullRequest {
  const GitHubPullRequest({required this.number});

  final int number;
}

final class GitHubRelease {
  const GitHubRelease({required this.htmlUrl});

  final String htmlUrl;
}

abstract interface class GitHubApi {
  Future<List<GitHubPullRequest>> listPullRequests({
    required String state,
    required String head,
    required String base,
    required int perPage,
  });

  Future<GitHubPullRequest> createPullRequest({
    required String head,
    required String base,
    required String title,
    required String body,
  });

  Future<void> updatePullRequest({
    required int number,
    required String title,
    required String body,
  });

  Future<bool> labelExists(String name);

  Future<void> createLabel({required String name, required String color});

  Future<void> addLabels({
    required int issueNumber,
    required List<String> labels,
  });

  Future<GitHubRelease?> releaseByTag(String tag);

  Future<GitHubRelease> createRelease({
    required String tag,
    required String name,
    required String body,
    required String targetCommitish,
  });
}

final class GitHubRestApi implements GitHubApi {
  GitHubRestApi({required this.context, http.Client? client, Uri? apiRoot})
    : _client = client ?? http.Client(),
      _apiRoot = apiRoot ?? Uri.parse('https://api.github.com');

  final GitHubContext context;
  final http.Client _client;
  final Uri _apiRoot;

  Uri _uri(String path, [Map<String, String>? query]) {
    final basePath = _apiRoot.path.endsWith('/')
        ? _apiRoot.path.substring(0, _apiRoot.path.length - 1)
        : _apiRoot.path;
    return _apiRoot.replace(path: '$basePath$path', queryParameters: query);
  }

  Map<String, String> get _headers => <String, String>{
    'Accept': 'application/vnd.github+json',
    'Authorization': 'Bearer ${context.token}',
    'X-GitHub-Api-Version': '2022-11-28',
    'Content-Type': 'application/json',
    'User-Agent': 'ship-my-flutter',
  };

  String get _repositoryPath =>
      '/repos/${Uri.encodeComponent(context.owner)}/'
      '${Uri.encodeComponent(context.repo)}';

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final request = http.Request(method, _uri(path, query))
      ..headers.addAll(_headers);
    if (body != null) request.body = jsonEncode(body);
    late final http.Response response;
    try {
      final streamed = await _client.send(request);
      response = await http.Response.fromStream(streamed);
    } on http.ClientException catch (error) {
      throw ShipError('Could not reach GitHub.', 'GITHUB_API', cause: error);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GitHubApiException(
        statusCode: response.statusCode,
        method: method,
        path: path,
        responseBody: _boundedBody(response.body),
      );
    }
    return response;
  }

  @override
  Future<List<GitHubPullRequest>> listPullRequests({
    required String state,
    required String head,
    required String base,
    required int perPage,
  }) async {
    final response = await _send(
      'GET',
      '$_repositoryPath/pulls',
      query: <String, String>{
        'state': state,
        'head': head,
        'base': base,
        'per_page': '$perPage',
      },
    );
    final data = _decodeResponse(response);
    if (data is! List<Object?>) {
      throw const ShipError(
        'GitHub returned an invalid pull request list.',
        'GITHUB_RESPONSE',
      );
    }
    return <GitHubPullRequest>[
      for (final item in data)
        GitHubPullRequest(number: _integerField(item, 'number')),
    ];
  }

  @override
  Future<GitHubPullRequest> createPullRequest({
    required String head,
    required String base,
    required String title,
    required String body,
  }) async {
    final response = await _send(
      'POST',
      '$_repositoryPath/pulls',
      body: <String, Object?>{
        'head': head,
        'base': base,
        'title': title,
        'body': body,
      },
    );
    return GitHubPullRequest(
      number: _integerField(_decodeResponse(response), 'number'),
    );
  }

  @override
  Future<void> updatePullRequest({
    required int number,
    required String title,
    required String body,
  }) async {
    await _send(
      'PATCH',
      '$_repositoryPath/pulls/$number',
      body: <String, Object?>{'title': title, 'body': body},
    );
  }

  @override
  Future<bool> labelExists(String name) async {
    try {
      await _send(
        'GET',
        '$_repositoryPath/labels/${Uri.encodeComponent(name)}',
      );
      return true;
    } on GitHubApiException catch (error) {
      if (error.statusCode == 404) return false;
      rethrow;
    }
  }

  @override
  Future<void> createLabel({
    required String name,
    required String color,
  }) async {
    await _send(
      'POST',
      '$_repositoryPath/labels',
      body: <String, Object?>{'name': name, 'color': color},
    );
  }

  @override
  Future<void> addLabels({
    required int issueNumber,
    required List<String> labels,
  }) async {
    await _send(
      'POST',
      '$_repositoryPath/issues/$issueNumber/labels',
      body: <String, Object?>{'labels': labels},
    );
  }

  @override
  Future<GitHubRelease?> releaseByTag(String tag) async {
    try {
      final response = await _send(
        'GET',
        '$_repositoryPath/releases/tags/${Uri.encodeComponent(tag)}',
      );
      return GitHubRelease(
        htmlUrl: _stringField(_decodeResponse(response), 'html_url'),
      );
    } on GitHubApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<GitHubRelease> createRelease({
    required String tag,
    required String name,
    required String body,
    required String targetCommitish,
  }) async {
    final response = await _send(
      'POST',
      '$_repositoryPath/releases',
      body: <String, Object?>{
        'tag_name': tag,
        'name': name,
        'body': body,
        'target_commitish': targetCommitish,
      },
    );
    return GitHubRelease(
      htmlUrl: _stringField(_decodeResponse(response), 'html_url'),
    );
  }
}

final class GitHubApiException implements Exception {
  const GitHubApiException({
    required this.statusCode,
    required this.method,
    required this.path,
    required this.responseBody,
  });

  final int statusCode;
  final String method;
  final String path;
  final String responseBody;

  @override
  String toString() {
    return 'GitHub API $method $path failed with status $statusCode: '
        '$responseBody';
  }
}

String _boundedBody(String body) =>
    body.length > 500 ? body.substring(0, 500) : body;

int _integerField(Object? value, String field) {
  if (value is Map<String, Object?>) {
    final fieldValue = value[field];
    if (fieldValue is int) return fieldValue;
  }
  throw ShipError(
    'GitHub response is missing integer field "$field".',
    'GITHUB_RESPONSE',
  );
}

String _stringField(Object? value, String field) {
  if (value is Map<String, Object?>) {
    final fieldValue = value[field];
    if (fieldValue is String) return fieldValue;
  }
  throw ShipError(
    'GitHub response is missing string field "$field".',
    'GITHUB_RESPONSE',
  );
}

Object? _decodeResponse(http.Response response) {
  try {
    return jsonDecode(response.body);
  } on FormatException catch (error) {
    throw ShipError(
      'GitHub returned malformed JSON.',
      'GITHUB_RESPONSE',
      cause: error,
    );
  }
}
