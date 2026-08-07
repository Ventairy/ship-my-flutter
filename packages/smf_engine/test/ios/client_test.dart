import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smf_engine/apple.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

final class ClientFixture {
  ClientFixture(List<http.Response> responses) : _responses = List<http.Response>.of(responses) {
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
      delay: (duration) async => delays.add(duration),
    );
  }

  final List<http.Response> _responses;
  final List<http.Request> requests = <http.Request>[];
  final List<Duration> delays = <Duration>[];
  late final MockClient httpClient;
  late final AppStoreConnectClient client;
}

final class TrackingClient extends http.BaseClient {
  bool isClosed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => throw UnimplementedError();

  @override
  void close() {
    isClosed = true;
  }
}

http.Response response(Object? body, [int status = 200]) => http.Response(
  status == 204 ? '' : jsonEncode(body),
  status,
  headers: const <String, String>{'content-type': 'application/json'},
);

Map<String, Object?> requestBody(http.Request request) => jsonDecode(request.body) as Map<String, Object?>;

void main() {
  group('App Store Connect client', () {
    test('closes its HTTP transport', () {
      final transport = TrackingClient();
      AppStoreConnectClient(
        const AppleCredentials(
          keyId: 'KEY123',
          issuerId: 'issuer',
          privateKey: 'unused',
        ),
        httpClient: transport,
      ).close();

      expect(transport.isClosed, isTrue);
    });

    test('maps transport failures to a typed API failure', () async {
      var attempts = 0;
      final client = AppStoreConnectClient(
        const AppleCredentials(
          keyId: 'KEY123',
          issuerId: 'issuer',
          privateKey: 'unused',
        ),
        httpClient: MockClient(
          (request) async {
            attempts++;
            throw http.ClientException('connection failed', request.url);
          },
        ),
        tokenProvider: () async => 'test-token',
        delay: (_) async {},
      );

      await expectLater(
        client.findApp('dev.example.app'),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.appStoreConnectApi,
          ),
        ),
      );
      expect(attempts, 3);
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
            SmfErrorCode.appStoreConnectResponse,
          ),
        ),
      );
    });

    test(
      'maps invalid optional attributes to a typed response failure',
      () async {
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
                  'version': '1',
                  'processingState': 'VALID',
                  'uploadedDate': 42,
                },
              },
            ],
          }),
        ]);

        await expectLater(
          fixture.client.buildsForVersion(
            appId: 'app-1',
            version: '1.2.0',
          ),
          throwsA(
            isA<SmfError>().having(
              (error) => error.code,
              'code',
              SmfErrorCode.appStoreConnectResponse,
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

    test('lists Apple signing resources with exact relationships', () async {
      final fixture = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'certificates',
              'id': 'certificate-1',
              'attributes': <String, Object?>{
                'certificateType': 'DISTRIBUTION',
                'displayName': 'Apple Distribution: Example',
                'serialNumber': 'AABBCCDD',
                'certificateContent': 'AQID',
                'expirationDate': '2027-07-27T12:00:00Z',
                'activated': true,
              },
            },
          ],
        }),
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'bundleIds',
              'id': 'bundle-1',
              'attributes': <String, Object?>{
                'identifier': 'dev.example.app',
                'platform': 'IOS',
              },
            },
          ],
        }),
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'profiles',
              'id': 'profile-1',
              'attributes': <String, Object?>{
                'name': 'Example App Store',
                'profileType': 'IOS_APP_STORE',
                'profileState': 'ACTIVE',
                'profileContent': 'BAUG',
                'uuid': 'PROFILE-UUID',
                'createdDate': '2026-07-27T12:00:00Z',
                'expirationDate': '2027-07-27T12:00:00Z',
              },
              'relationships': <String, Object?>{
                'bundleId': <String, Object?>{
                  'data': <String, Object?>{
                    'type': 'bundleIds',
                    'id': 'bundle-1',
                  },
                },
                'certificates': <String, Object?>{
                  'data': <Object?>[
                    <String, Object?>{
                      'type': 'certificates',
                      'id': 'certificate-1',
                    },
                  ],
                },
              },
            },
          ],
        }),
      ]);

      final certificates = await fixture.client.listSigningCertificates();
      final bundleIds = await fixture.client.listIosBundleIds();
      final profiles = await fixture.client.listAppStoreProfiles();

      expect(certificates.single.id, 'certificate-1');
      expect(certificates.single.certificateType, 'DISTRIBUTION');
      expect(bundleIds.single.identifier, 'dev.example.app');
      expect(profiles.single.bundleIdId, 'bundle-1');
      expect(profiles.single.certificateIds, <String>['certificate-1']);
      expect(
        fixture.requests[2].url.query,
        contains('filter%5BprofileType%5D=IOS_APP_STORE'),
      );
    });

    test(
      'creates one App Store profile for an exact bundle and certificate',
      () async {
        final fixture = ClientFixture(<http.Response>[
          response(
            <String, Object?>{
              'data': <String, Object?>{
                'type': 'profiles',
                'id': 'profile-1',
                'attributes': <String, Object?>{
                  'name': 'SMF App Store dev.example.app AABBCCDD',
                  'profileType': 'IOS_APP_STORE',
                  'profileState': 'ACTIVE',
                  'profileContent': 'BAUG',
                  'uuid': 'PROFILE-UUID',
                  'createdDate': '2026-07-27T12:00:00Z',
                  'expirationDate': '2027-07-27T12:00:00Z',
                },
                'relationships': <String, Object?>{
                  'bundleId': <String, Object?>{
                    'data': <String, Object?>{
                      'type': 'bundleIds',
                      'id': 'bundle-1',
                    },
                  },
                  'certificates': <String, Object?>{
                    'data': <Object?>[
                      <String, Object?>{
                        'type': 'certificates',
                        'id': 'certificate-1',
                      },
                    ],
                  },
                },
              },
            },
            201,
          ),
        ]);

        final profile = await fixture.client.createAppStoreProfile(
          name: 'SMF App Store dev.example.app AABBCCDD',
          bundleIdId: 'bundle-1',
          certificateId: 'certificate-1',
        );

        expect(profile.id, 'profile-1');
        final body = requestBody(fixture.requests.single);
        final data = body['data']! as Map<String, Object?>;
        expect(data['attributes'], <String, Object?>{
          'name': 'SMF App Store dev.example.app AABBCCDD',
          'profileType': 'IOS_APP_STORE',
        });
        expect(jsonEncode(data['relationships']), contains('certificate-1'));
      },
    );

    test('retries transient GET failures', () async {
      final fixture = ClientFixture(<http.Response>[
        http.Response(
          jsonEncode(<String, Object?>{
            'errors': <Object?>[
              <String, Object?>{'detail': 'Try again'},
            ],
          }),
          429,
          headers: const <String, String>{'retry-after': '7'},
        ),
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

      expect((await fixture.client.findApp('dev.example.app')).id, 'app-1');
      expect(fixture.requests, hasLength(2));
      expect(fixture.delays, <Duration>[const Duration(seconds: 7)]);
    });

    test('does not retry a profile-creation mutation', () async {
      final fixture = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'errors': <Object?>[
            <String, Object?>{'detail': 'Try again'},
          ],
        }, 503),
        response(<String, Object?>{'data': <String, Object?>{}}, 201),
      ]);

      await expectLater(
        fixture.client.createAppStoreProfile(
          name: 'SMF App Store dev.example.app AABBCCDD',
          bundleIdId: 'bundle-1',
          certificateId: 'certificate-1',
        ),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.appStoreConnectApi,
          ),
        ),
      );
      expect(fixture.requests, hasLength(1));
    });

    test(
      'calculates an integer build number above integer and dotted histories',
      () async {
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
                  'version': '12.42.7',
                  'processingState': 'VALID',
                },
              },
            ],
          }),
        ]);
        expect(
          await fixture.client.nextBuildNumber(
            appId: 'app-1',
            version: '1.2.0',
          ),
          '13',
        );
      },
    );

    test('rejects a malformed build number returned by Apple', () async {
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
                'version': '12.beta',
                'processingState': 'VALID',
              },
            },
          ],
        }),
      ]);

      await expectLater(
        fixture.client.nextBuildNumber(
          appId: 'app-1',
          version: '1.2.0',
        ),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.appStoreConnectResponse,
          ),
        ),
      );
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
            SmfErrorCode.appStoreConnectOrigin,
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
        appId: 'app-1',
        version: '1.2.0',
        buildNumber: '13',
        timeoutMinutes: 5,
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
          appId: 'app-1',
          version: '1.2.0',
          buildNumber: '13',
          timeoutMinutes: 5,
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
      await existing.client.setBetaBuildLocalization(
        buildId: 'build-1',
        locale: 'en-US',
        whatsNew: 'New',
      );
      expect(
        requestBody(existing.requests[1])['data'],
        containsPair('attributes', <String, Object?>{'whatsNew': 'New'}),
      );

      final created = ClientFixture(<http.Response>[
        response(<String, Object?>{'data': <Object?>[]}),
        response(null, 204),
      ]);
      await created.client.setBetaBuildLocalization(
        buildId: 'build-1',
        locale: 'pt-BR',
        whatsNew: 'Novo',
      );
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
              'attributes': <String, Object?>{
                'name': 'Internal',
                'isInternalGroup': true,
              },
            },
            <String, Object?>{
              'type': 'betaGroups',
              'id': 'internal-2',
              'attributes': <String, Object?>{
                'name': 'Internal 2',
                'isInternalGroup': true,
              },
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
      await fixture.client.addBuildToGroups(
        appId: 'app-1',
        buildId: 'build-1',
        names: const <String>['Internal', 'Internal 2'],
        isInternal: true,
      );
      expect(fixture.requests, hasLength(4));
      expect(
        fixture.requests.last.url.path,
        '/v1/betaGroups/internal-2/relationships/builds',
      );
    });

    test('rejects a TestFlight group from the wrong audience', () async {
      final fixture = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'betaGroups',
              'id': 'external',
              'attributes': <String, Object?>{
                'name': 'Public Beta',
                'isInternalGroup': false,
              },
            },
          ],
        }),
      ]);

      await expectLater(
        fixture.client.addBuildToGroups(
          appId: 'app-1',
          buildId: 'build-1',
          names: const <String>['Public Beta'],
          isInternal: true,
        ),
        throwsA(
          isA<SmfError>().having(
            (error) => error.code,
            'code',
            SmfErrorCode.betaGroupAudienceMismatch,
          ),
        ),
      );
    });

    test('submits a build for Beta App Review idempotently', () async {
      final existing = ClientFixture(<http.Response>[
        response(<String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'type': 'betaAppReviewSubmissions',
              'id': 'beta-review-1',
              'attributes': <String, Object?>{
                'betaReviewState': 'APPROVED',
              },
            },
          ],
        }),
      ]);

      expect(
        await existing.client.submitBuildForBetaReview('build-1'),
        'beta-review-1',
      );
      expect(existing.requests, hasLength(1));

      final created = ClientFixture(<http.Response>[
        response(<String, Object?>{'data': <Object?>[]}),
        response(<String, Object?>{
          'data': <String, Object?>{
            'type': 'betaAppReviewSubmissions',
            'id': 'beta-review-2',
            'attributes': <String, Object?>{
              'betaReviewState': 'WAITING_FOR_REVIEW',
            },
          },
        }, 201),
      ]);

      expect(
        await created.client.submitBuildForBetaReview('build-2'),
        'beta-review-2',
      );
      expect(
        requestBody(created.requests.last)['data'],
        containsPair(
          'relationships',
          <String, Object?>{
            'build': <String, Object?>{
              'data': <String, Object?>{
                'type': 'builds',
                'id': 'build-2',
              },
            },
          },
        ),
      );
    });

    test(
      'when Beta App Review rejected a build, it should require a new build instead of resubmitting it',
      () async {
        final fixture = ClientFixture(<http.Response>[
          response(<String, Object?>{
            'data': <Object?>[
              <String, Object?>{
                'type': 'betaAppReviewSubmissions',
                'id': 'beta-review-1',
                'attributes': <String, Object?>{
                  'betaReviewState': 'REJECTED',
                },
              },
            ],
          }),
        ]);

        await expectLater(
          fixture.client.submitBuildForBetaReview('build-1'),
          throwsA(
            isA<SmfError>().having(
              (error) => error.code,
              'code',
              SmfErrorCode.betaReviewRejected,
            ),
          ),
        );
      },
    );

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
                'appVersionState': 'PREPARE_FOR_SUBMISSION',
                'releaseType': 'MANUAL',
              },
            },
          }),
          response(null, 204),
        ]);
        final version = await create.client.findOrCreateAppStoreVersion(
          appId: 'app-1',
          version: '2.0.0',
          shouldReleaseAutomatically: false,
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
        await create.client.attachBuildToVersion(
          appStoreVersionId: version.id,
          buildId: 'build-1',
        );
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
                  'appVersionState': 'PREPARE_FOR_SUBMISSION',
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
                'appVersionState': 'PREPARE_FOR_SUBMISSION',
                'releaseType': 'AFTER_APPROVAL',
              },
            },
          }),
        ]);
        final updated = await update.client.findOrCreateAppStoreVersion(
          appId: 'app-1',
          version: '2.0.0',
          shouldReleaseAutomatically: true,
        );
        expect(
          updated.attributes.releaseType,
          AppStoreReleaseType.afterApproval,
        );
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
      await notes.client.setAppStoreReleaseNotes(
        appStoreVersionId: 'version-1',
        locale: 'en-US',
        whatsNew: 'Ready',
      );
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
        await review.client.submitVersionForReview(
          appId: 'app-1',
          appStoreVersionId: 'version-1',
        ),
        'submission-1',
      );
      final finalData = requestBody(review.requests.last)['data']! as Map<String, Object?>;
      expect(finalData['attributes'], <String, Object?>{'isSubmitted': true});
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
        await fixture.client.submitVersionForReview(
          appId: 'app-1',
          appStoreVersionId: 'version-1',
        ),
        'submission-1',
      );
      expect(fixture.requests, hasLength(1));
    });

    test(
      'when a review submission is ready but not isSubmitted, it should submit the existing review',
      () async {
        final fixture = ClientFixture(<http.Response>[
          response(<String, Object?>{
            'data': <Object?>[
              <String, Object?>{
                'type': 'reviewSubmissions',
                'id': 'submission-1',
                'attributes': <String, Object?>{'state': 'READY_FOR_REVIEW'},
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
          response(null, 204),
        ]);

        await fixture.client.submitVersionForReview(
          appId: 'app-1',
          appStoreVersionId: 'version-1',
        );

        expect(
          requestBody(fixture.requests.last)['data'],
          containsPair(
            'attributes',
            <String, Object?>{'isSubmitted': true},
          ),
        );
      },
    );

    test(
      'when Apple completed review for the same version, it should reuse the completed submission',
      () async {
        final fixture = ClientFixture(<http.Response>[
          response(<String, Object?>{
            'data': <Object?>[
              <String, Object?>{
                'type': 'reviewSubmissions',
                'id': 'submission-1',
                'attributes': <String, Object?>{'state': 'COMPLETE'},
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
          await fixture.client.submitVersionForReview(
            appId: 'app-1',
            appStoreVersionId: 'version-1',
          ),
          'submission-1',
        );
      },
    );

    test(
      'when App Review reports unresolved issues, it should stop before creating another submission',
      () async {
        final fixture = ClientFixture(<http.Response>[
          response(<String, Object?>{
            'data': <Object?>[
              <String, Object?>{
                'type': 'reviewSubmissions',
                'id': 'submission-1',
                'attributes': <String, Object?>{
                  'state': 'UNRESOLVED_ISSUES',
                },
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

        await expectLater(
          fixture.client.submitVersionForReview(
            appId: 'app-1',
            appStoreVersionId: 'version-1',
          ),
          throwsA(
            isA<SmfError>().having(
              (error) => error.code,
              'code',
              SmfErrorCode.appReviewUnresolved,
            ),
          ),
        );
      },
    );

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
