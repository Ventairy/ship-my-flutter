import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smf_apple/smf_apple.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

final class ClientFixture {
  ClientFixture(List<http.Response> responses)
    : _responses = List<http.Response>.of(responses) {
    httpClient = MockClient((request) async {
      requests.add(request);
      if (_responses.isEmpty) {
        throw StateError('Unexpected request ${request.method} ${request.url}');
      }
      return _responses.removeAt(0);
    });
    client = AppStoreConnectClient(
      const AppleCredentials(
        keyId: 'KEY123',
        issuerId: 'issuer',
        privateKey: 'unused',
      ),
      httpClient: httpClient,
      tokenProvider: () async => 'test-token',
    );
  }

  final List<http.Response> _responses;
  final List<http.Request> requests = <http.Request>[];
  late final MockClient httpClient;
  late final AppStoreConnectClient client;
}

http.Response response(Object? body, [int status = 200]) => http.Response(
  status == 204 ? '' : jsonEncode(body),
  status,
  headers: const <String, String>{'content-type': 'application/json'},
);

Map<String, Object?> requestBody(http.Request request) =>
    jsonDecode(request.body) as Map<String, Object?>;

void main() {
  group('App Store Connect client', () {
    test('maps transport failures to a typed API failure', () async {
      final client = AppStoreConnectClient(
        const AppleCredentials(
          keyId: 'KEY123',
          issuerId: 'issuer',
          privateKey: 'unused',
        ),
        httpClient: MockClient(
          (request) async =>
              throw http.ClientException('connection failed', request.url),
        ),
        tokenProvider: () async => 'test-token',
      );

      await expectLater(
        client.findApp('dev.example.app'),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'APP_STORE_CONNECT_API',
          ),
        ),
      );
    });

    test('maps malformed JSON to a typed response failure', () async {
      final fixture = ClientFixture(<http.Response>[
        http.Response('{not-json', 200),
      ]);

      await expectLater(
        fixture.client.findApp('dev.example.app'),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'APP_STORE_CONNECT_RESPONSE',
          ),
        ),
      );
    });

    test(
      'maps invalid optional attributes to a typed response failure',
      () async {
        final fixture = ClientFixture(<http.Response>[
          response(<String, Object?>{
            'data': <String, Object?>{
              'type': 'builds',
              'id': 'build-1',
              'attributes': <String, Object?>{
                'version': '1',
                'processingState': 'VALID',
                'uploadedDate': 42,
              },
            },
          }),
        ]);

        await expectLater(
          fixture.client.getBuild('build-1'),
          throwsA(
            isA<SmfError>().having(
              (error) => error.code,
              'code',
              'APP_STORE_CONNECT_RESPONSE',
            ),
          ),
        );
      },
    );

    test('finds an app by exact bundle identifier', () async {
      final fixture = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'apps',
              'id': 'app-1',
              'attributes': <String, Object?>{
                'name': 'Example',
                'bundleId': 'dev.example.app',
                'sku': 'example',
                'primaryLocale': 'en-US',
              },
            },
          ],
        }),
      ]);
      final app = await fixture.client.findApp('dev.example.app');
      expect(app.id, 'app-1');
      expect(
        fixture.requests.single.url.query,
        contains('filter%5BbundleId%5D=dev.example.app'),
      );
    });

    test('rejects a missing app instead of guessing', () async {
      final fixture = ClientFixture(<http.Response>[
        response(<String, Object?>{'data': <Object?>[]}),
      ]);
      await expectLater(
        fixture.client.findApp('dev.example.missing'),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('No App Store Connect app found'),
          ),
        ),
      );
    });

    test('calculates the next integer build number', () async {
      final fixture = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'preReleaseVersions',
              'id': 'pre-1',
              'attributes': <String, Object?>{
                'version': '1.2.0',
                'platform': 'IOS',
              },
            },
          ],
        }),
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'builds',
              'id': 'build-1',
              'attributes': <String, Object?>{
                'version': '8',
                'processingState': 'VALID',
              },
            },
            <String, Object?>{
              'type': 'builds',
              'id': 'build-2',
              'attributes': <String, Object?>{
                'version': '12',
                'processingState': 'VALID',
              },
            },
          ],
        }),
      ]);
      expect(await fixture.client.nextBuildNumber('app-1', '1.2.0'), '13');
    });

    test('follows collection pagination and rejects another origin', () async {
      final fixture = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'preReleaseVersions',
              'id': 'pre-1',
              'attributes': <String, Object?>{
                'version': '1.0.0',
                'platform': 'IOS',
              },
            },
          ],
          'links': <String, Object?>{
            'next':
                'https://api.appstoreconnect.apple.com/v1/'
                'preReleaseVersions?cursor=next',
          },
        }),
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'preReleaseVersions',
              'id': 'pre-2',
              'attributes': <String, Object?>{
                'version': '2.0.0',
                'platform': 'IOS',
              },
            },
          ],
        }),
      ]);
      expect(
        await fixture.client.listPrereleaseVersions('app-1'),
        hasLength(2),
      );
      expect(fixture.requests, hasLength(2));

      final malicious = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[],
          'links': <String, Object?>{'next': 'https://example.invalid/steal'},
        }),
      ]);
      await expectLater(
        malicious.client.listPrereleaseVersions('app-1'),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            'APP_STORE_CONNECT_ORIGIN',
          ),
        ),
      );
    });

    test('waits for the exact build and fails invalid builds', () async {
      final valid = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'preReleaseVersions',
              'id': 'pre-1',
              'attributes': <String, Object?>{
                'version': '1.2.0',
                'platform': 'IOS',
              },
            },
          ],
        }),
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'builds',
              'id': 'build-13',
              'attributes': <String, Object?>{
                'version': '13',
                'processingState': 'VALID',
              },
            },
          ],
        }),
      ]);
      final build = await valid.client.waitForBuild(
        'app-1',
        '1.2.0',
        '13',
        5,
        interval: Duration.zero,
      );
      expect(build.id, 'build-13');

      final invalid = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'preReleaseVersions',
              'id': 'pre-1',
              'attributes': <String, Object?>{
                'version': '1.2.0',
                'platform': 'IOS',
              },
            },
          ],
        }),
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'builds',
              'id': 'build-13',
              'attributes': <String, Object?>{
                'version': '13',
                'processingState': 'INVALID',
              },
            },
          ],
        }),
      ]);
      await expectLater(
        invalid.client.waitForBuild(
          'app-1',
          '1.2.0',
          '13',
          5,
          interval: Duration.zero,
        ),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            contains('marked 1.2.0 (13) as INVALID'),
          ),
        ),
      );
    });

    test('updates or creates TestFlight localizations', () async {
      final existing = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'betaBuildLocalizations',
              'id': 'localization-1',
              'attributes': <String, Object?>{
                'locale': 'en-US',
                'whatsNew': 'Old',
              },
            },
          ],
        }),
        response(null, 204),
      ]);
      await existing.client.setBetaBuildLocalization('build-1', 'en-US', 'New');
      expect(
        requestBody(existing.requests[1])['data'],
        containsPair('attributes', <String, Object?>{'whatsNew': 'New'}),
      );

      final created = ClientFixture(<http.Response>[
        response(<String, Object?>{'data': <Object?>[]}),
        response(null, 204),
      ]);
      await created.client.setBetaBuildLocalization('build-1', 'pt-BR', 'Novo');
      final data = requestBody(created.requests[1])['data'];
      expect(data, isA<Map<String, Object?>>());
      expect(
        data! as Map<String, Object?>,
        containsPair('attributes', <String, Object?>{
          'locale': 'pt-BR',
          'whatsNew': 'Novo',
        }),
      );
    });

    test('assigns named TestFlight groups idempotently', () async {
      final fixture = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'betaGroups',
              'id': 'internal',
              'attributes': <String, Object?>{'name': 'Internal'},
            },
            <String, Object?>{
              'type': 'betaGroups',
              'id': 'external',
              'attributes': <String, Object?>{'name': 'External'},
            },
          ],
        }),
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{'type': 'builds', 'id': 'build-1'},
          ],
        }),
        response(<String, Object?>{'data': <Object?>[]}),
        response(null, 204),
      ]);
      await fixture.client.addBuildToGroups('app-1', 'build-1', const <String>[
        'Internal',
        'External',
      ]);
      expect(fixture.requests, hasLength(4));
      expect(
        fixture.requests.last.url.path,
        '/v1/betaGroups/external/relationships/builds',
      );
    });

    test(
      'creates a version, attaches a build, and updates release policy',
      () async {
        final create = ClientFixture(<http.Response>[
          response(<String, Object?>{'data': <Object?>[]}),
          response(<String, Object?>{
            'data': <String, Object?>{
              'type': 'appStoreVersions',
              'id': 'version-1',
              'attributes': <String, Object?>{
                'platform': 'IOS',
                'versionString': '2.0.0',
                'appStoreState': 'PREPARE_FOR_SUBMISSION',
                'releaseType': 'MANUAL',
              },
            },
          }),
          response(null, 204),
        ]);
        final version = await create.client.findOrCreateAppStoreVersion(
          'app-1',
          '2.0.0',
          releaseAutomatically: false,
        );
        expect(requestBody(create.requests[1]), <String, Object?>{
          'data': <String, Object?>{
            'type': 'appStoreVersions',
            'attributes': <String, Object?>{
              'platform': 'IOS',
              'versionString': '2.0.0',
              'releaseType': 'MANUAL',
            },
            'relationships': <String, Object?>{
              'app': <String, Object?>{
                'data': <String, Object?>{'type': 'apps', 'id': 'app-1'},
              },
            },
          },
        });
        await create.client.attachBuildToVersion(version.id, 'build-1');
        expect(version.id, 'version-1');
        expect(requestBody(create.requests.last), <String, Object?>{
          'data': <String, Object?>{'type': 'builds', 'id': 'build-1'},
        });

        final update = ClientFixture(<http.Response>[
          response(<String, Object?>{
            'data': <Object?>[
              <String, Object?>{
                'type': 'appStoreVersions',
                'id': 'version-1',
                'attributes': <String, Object?>{
                  'platform': 'IOS',
                  'versionString': '2.0.0',
                  'appStoreState': 'PREPARE_FOR_SUBMISSION',
                  'releaseType': 'MANUAL',
                },
              },
            ],
          }),
          response(<String, Object?>{
            'data': <String, Object?>{
              'type': 'appStoreVersions',
              'id': 'version-1',
              'attributes': <String, Object?>{
                'platform': 'IOS',
                'versionString': '2.0.0',
                'appStoreState': 'PREPARE_FOR_SUBMISSION',
                'releaseType': 'AFTER_APPROVAL',
              },
            },
          }),
        ]);
        final updated = await update.client.findOrCreateAppStoreVersion(
          'app-1',
          '2.0.0',
          releaseAutomatically: true,
        );
        expect(updated.attributes.releaseType, 'AFTER_APPROVAL');
        expect(requestBody(update.requests.last), <String, Object?>{
          'data': <String, Object?>{
            'type': 'appStoreVersions',
            'id': 'version-1',
            'attributes': <String, Object?>{'releaseType': 'AFTER_APPROVAL'},
          },
        });
      },
    );

    test('updates App Store notes and submits the review workflow', () async {
      final notes = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'appStoreVersionLocalizations',
              'id': 'store-loc-1',
              'attributes': <String, Object?>{
                'locale': 'en-US',
                'whatsNew': '',
              },
            },
          ],
        }),
        response(null, 204),
      ]);
      await notes.client.setAppStoreReleaseNotes('version-1', 'en-US', 'Ready');
      expect(
        notes.requests.last.url.path,
        '/v1/appStoreVersionLocalizations/store-loc-1',
      );

      final review = ClientFixture(<http.Response>[
        response(<String, Object?>{'data': <Object?>[]}),
        response(<String, Object?>{
          'data': <String, Object?>{
            'type': 'reviewSubmissions',
            'id': 'submission-1',
            'attributes': <String, Object?>{'state': 'READY_FOR_REVIEW'},
          },
        }),
        response(null, 204),
        response(null, 204),
      ]);
      expect(
        await review.client.submitVersionForReview('app-1', 'version-1'),
        'submission-1',
      );
      final finalData =
          requestBody(review.requests.last)['data']! as Map<String, Object?>;
      expect(finalData['attributes'], <String, Object?>{'submitted': true});
    });

    test('reuses an active review submission for the same version', () async {
      final fixture = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'reviewSubmissions',
              'id': 'submission-1',
              'attributes': <String, Object?>{'state': 'WAITING_FOR_REVIEW'},
              'relationships': <String, Object?>{
                'appStoreVersionForReview': <String, Object?>{
                  'data': <String, Object?>{
                    'type': 'appStoreVersions',
                    'id': 'version-1',
                  },
                },
              },
            },
          ],
        }),
      ]);
      expect(
        await fixture.client.submitVersionForReview('app-1', 'version-1'),
        'submission-1',
      );
      expect(fixture.requests, hasLength(1));
    });

    test('surfaces structured Apple errors without credentials', () async {
      final fixture = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'errors': <Object?>[
            <String, Object?>{
              'code': 'ENTITY_ERROR',
              'title': 'The request is invalid',
              'detail': 'Missing metadata',
            },
          ],
        }, 409),
      ]);
      await expectLater(
        fixture.client.findApp('dev.example.app'),
        throwsA(
          isA<SmfError>().having(
            (error) => error.message,
            'message',
            allOf(contains('ENTITY_ERROR'), contains('Missing metadata')),
          ),
        ),
      );
    });
  });
}
