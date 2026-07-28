import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

final class _TrackingClient extends http.BaseClient {
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(const Stream<List<int>>.empty(), 204);
  }

  @override
  void close() {
    closed = true;
    super.close();
  }
}

void main() {
  test('when the GitHub client closes, it should close its transport', () {
    final transport = _TrackingClient();
    GitHubRestApi(
      context: const GitHubContext(owner: 'o', repo: 'r', token: 'secret'),
      client: transport,
    ).close();

    expect(transport.closed, isTrue);
  });

  test(
    'GitHub REST client maps transport failures to a typed failure',
    () async {
      final api = GitHubRestApi(
        context: const GitHubContext(owner: 'o', repo: 'r', token: 'secret'),
        client: MockClient(
          (request) async => throw http.ClientException('connection failed', request.url),
        ),
      );
      addTearDown(api.close);

      await expectLater(
        api.listPullRequests(
          state: 'open',
          head: 'o:smf/ios',
          base: 'main',
          perPage: 1,
        ),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'GITHUB_API',
          ),
        ),
      );
    },
  );

  test(
    'GitHub REST client sends native API requests and maps resources',
    () async {
      final requests = <http.Request>[];
      final responses = <http.Response>[
        http.Response('[{"number":12}]', 200),
        http.Response('{"number":13}', 201),
        http.Response('', 204),
        http.Response('{"message":"Not Found"}', 404),
        http.Response(
          '{"html_url":"https://github.com/o/r/releases/tag/ios-v1.0.0"}',
          201,
        ),
      ];
      final api = GitHubRestApi(
        context: const GitHubContext(owner: 'o', repo: 'r', token: 'secret'),
        client: MockClient((request) async {
          requests.add(request);
          return responses.removeAt(0);
        }),
      );
      addTearDown(api.close);

      expect(
        (await api.listPullRequests(
          state: 'open',
          head: 'o:smf/ios',
          base: 'main',
          perPage: 1,
        )).single.number,
        12,
      );
      expect(
        (await api.createPullRequest(
          head: 'smf/ios',
          base: 'main',
          title: 'release',
          body: 'body',
        )).number,
        13,
      );
      await api.updatePullRequest(number: 13, title: 'updated', body: 'body');
      expect(await api.releaseByTag('missing'), isNull);
      final release = await api.createRelease(
        tag: 'ios-v1.0.0',
        name: 'iOS v1.0.0',
        body: 'notes',
        targetCommitish: 'sha',
      );
      expect(release.htmlUrl, contains('ios-v1.0.0'));

      expect(requests.first.headers['authorization'], 'Bearer secret');
      expect(requests.first.url.path, '/repos/o/r/pulls');
      expect(requests.first.url.queryParameters['head'], 'o:smf/ios');
      expect(jsonDecode(requests[1].body), containsPair('head', 'smf/ios'));
    },
  );

  test('GitHub REST failures preserve status and operation', () async {
    final api = GitHubRestApi(
      context: const GitHubContext(owner: 'o', repo: 'r', token: 'secret'),
      client: MockClient(
        (_) async => http.Response('{"message":"forbidden"}', 403),
      ),
    );
    addTearDown(api.close);
    await expectLater(
      api.labelExists('pending'),
      throwsA(
        isA<GitHubApiException>()
            .having(
              (error) => error.statusCode,
              'statusCode',
              403,
            )
            .having(
              (error) => error.path,
              'path',
              contains('/labels/pending'),
            ),
      ),
    );
  });

  test('GitHub REST client maps malformed JSON to a typed failure', () async {
    final api = GitHubRestApi(
      context: const GitHubContext(owner: 'o', repo: 'r', token: 'secret'),
      client: MockClient((_) async => http.Response('{not-json', 200)),
    );
    addTearDown(api.close);

    await expectLater(
      api.listPullRequests(
        state: 'open',
        head: 'o:smf/ios',
        base: 'main',
        perPage: 1,
      ),
      throwsA(
        isA<SmfError>().having(
          (error) => error.code,
          'code',
          'GITHUB_RESPONSE',
        ),
      ),
    );
  });
}
