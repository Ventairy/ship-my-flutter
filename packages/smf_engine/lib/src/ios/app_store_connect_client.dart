import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/ios/app_store_connect_api.dart';
import 'package:smf_engine/src/ios/dtos/api_resource_dto.dart';
import 'package:smf_engine/src/ios/dtos/app_attributes_dto.dart';
import 'package:smf_engine/src/ios/dtos/app_store_version_attributes_dto.dart';
import 'package:smf_engine/src/ios/dtos/build_attributes_dto.dart';
import 'package:smf_engine/src/ios/dtos/prerelease_version_attributes_dto.dart';
import 'package:smf_engine/src/ios/dtos/review_submission_dto.dart';
import 'package:smf_engine/src/ios/dtos/signing_assets_dtos.dart';
import 'package:smf_engine/src/ios/enums/app_store_release_type.dart';
import 'package:smf_engine/src/ios/enums/apple_platform.dart';
import 'package:smf_engine/src/ios/enums/beta_review_state.dart';
import 'package:smf_engine/src/ios/enums/build_processing_state.dart';
import 'package:smf_engine/src/ios/enums/review_submission_state.dart';
import 'package:smf_engine/src/ios/models/apple_credentials.dart';

/// Authenticated App Store Connect implementation used by SMF.
final class AppStoreConnectClient implements AppStoreConnectApi {
  /// Creates an App Store Connect client.
  ///
  /// [currentTime] and [delay] are deterministic seams for build-processing
  /// polling. Normal consumers should leave them unset.
  AppStoreConnectClient(
    this.credentials, {
    http.Client? httpClient,
    Future<String> Function()? tokenProvider,
    Uri? baseUrl,
    DateTime Function()? currentTime,
    Future<void> Function(Duration)? delay,
  }) : _httpClient = httpClient ?? http.Client(),
       _tokenProvider = tokenProvider,
       _currentTime = currentTime ?? _systemTime,
       _delay = delay ?? _systemDelay,
       baseUrl = baseUrl ?? Uri.parse('https://api.appstoreconnect.apple.com');

  final AppleCredentials credentials;
  final http.Client _httpClient;
  final Future<String> Function()? _tokenProvider;
  final DateTime Function() _currentTime;
  final Future<void> Function(Duration) _delay;
  final Uri baseUrl;

  static DateTime _systemTime() => DateTime.now();

  static Future<void> _systemDelay(Duration duration) => Future<void>.delayed(duration);

  @override
  void close() => _httpClient.close();

  Future<String> _token() async {
    final override = _tokenProvider;
    if (override != null) return override();
    final jwt = JWT(
      <String, Object?>{},
      issuer: credentials.issuerId,
      audience: Audience.one('appstoreconnect-v1'),
      header: <String, dynamic>{
        'alg': 'ES256',
        'kid': credentials.keyId,
        'typ': 'JWT',
      },
    );
    return jwt.sign(
      ECPrivateKey(credentials.privateKey),
      algorithm: JWTAlgorithm.ES256,
      expiresIn: const Duration(minutes: 19),
    );
  }

  static const Set<int> _retryableGetStatuses = <int>{
    429,
    500,
    502,
    503,
    504,
  };

  Future<Object?> _request(String method, String path, {Object? body}) async {
    final url = baseUrl.resolve(path);
    SmfError.check(
      url.origin == baseUrl.origin,
      'App Store Connect pagination returned an unexpected origin.',
      SmfErrorCode.appStoreConnectOrigin,
    );
    http.Response? response;
    for (var attempt = 0; ; attempt++) {
      final request = http.Request(method, url)
        ..headers.addAll(<String, String>{
          'Authorization': 'Bearer ${await _token()}',
          'Accept': 'application/json',
          if (body != null) 'Content-Type': 'application/json',
        });
      if (body != null) request.body = jsonEncode(body);
      try {
        final streamed = await _httpClient.send(request);
        response = await http.Response.fromStream(streamed);
      } on http.ClientException catch (error) {
        if (method == 'GET' && attempt < 2) {
          await _delay(Duration(seconds: attempt + 1));
          continue;
        }
        throw SmfError(
          'Could not reach App Store Connect.',
          SmfErrorCode.appStoreConnectApi,
          cause: error,
        );
      }
      if (method != 'GET' || !_retryableGetStatuses.contains(response.statusCode) || attempt >= 2) {
        break;
      }
      await _delay(_retryDelay(response, attempt));
    }
    final completedResponse = response;
    if (completedResponse.statusCode < 200 || completedResponse.statusCode >= 300) {
      String? details;
      try {
        final document = _map(
          jsonDecode(completedResponse.body),
          'error document',
        );
        final errors = document['errors'];
        if (errors is List<Object?>) {
          details = errors
              .map((value) {
                final error = _map(value, 'error');
                return <Object?>[
                  error['code'],
                  error['title'],
                  error['detail'],
                ].whereType<String>().join(': ');
              })
              .where((value) => value.isNotEmpty)
              .join('; ');
        }
      } on FormatException {
        details = null;
      } on SmfError {
        details = null;
      }
      final requestTarget = '${url.path}${url.hasQuery ? '?${url.query}' : ''}';
      throw SmfError(
        'App Store Connect $method $requestTarget '
        'failed (${completedResponse.statusCode})'
        '${details == null || details.isEmpty ? '' : ': $details'}',
        SmfErrorCode.appStoreConnectApi,
      );
    }
    if (completedResponse.statusCode == 204 || completedResponse.body.isEmpty) {
      return null;
    }
    return _decodeResponseBody(completedResponse.body);
  }

  Duration _retryDelay(http.Response response, int attempt) {
    final retryAfter = int.tryParse(
      response.headers['retry-after']?.trim() ?? '',
    );
    if (retryAfter != null && retryAfter > 0) {
      return Duration(seconds: retryAfter.clamp(1, 60));
    }
    return Duration(seconds: attempt + 1);
  }

  Future<List<Object?>> _collection(String path) async {
    final data = <Object?>[];
    final seen = <String>{};
    String? next = path;
    while (next != null) {
      SmfError.check(
        seen.add(next),
        'App Store Connect returned a pagination loop.',
        SmfErrorCode.appStoreConnectPagination,
      );
      final page = _map(await _request('GET', next), 'collection');
      data.addAll(_list(page['data'], 'collection.data'));
      final links = page['links'];
      next = links == null
          ? null
          : _optionalString(
              _map(links, 'collection.links')['next'],
              'collection.links.next',
            );
    }
    return data;
  }

  @override
  Future<ApiResourceDto<AppAttributesDto>> findApp(String bundleId) async {
    final query = Uri(
      queryParameters: <String, String>{'filter[bundleId]': bundleId},
    ).query;
    final response = _map(await _request('GET', '/v1/apps?$query'), 'apps');
    final data = _list(response['data'], 'apps.data');
    SmfError.check(
      data.length == 1,
      data.isEmpty
          ? 'No App Store Connect app found for $bundleId'
          : 'Multiple App Store Connect apps found for $bundleId',
      SmfErrorCode.appNotFound,
    );
    return _appResource(data.single);
  }

  @override
  Future<List<AppleSigningCertificateDto>> listSigningCertificates() async {
    final query = Uri(
      queryParameters: <String, String>{
        'fields[certificates]':
            'certificateType,displayName,serialNumber,expirationDate,'
            'certificateContent,activated',
        'limit': '200',
      },
    ).query;
    return <AppleSigningCertificateDto>[
      for (final item in await _collection('/v1/certificates?$query')) _signingCertificate(item),
    ];
  }

  @override
  Future<List<AppleBundleIdentifierDto>> listIosBundleIds() async {
    final query = Uri(
      queryParameters: <String, String>{
        'filter[platform]': 'IOS',
        'fields[bundleIds]': 'identifier,platform',
        'limit': '200',
      },
    ).query;
    return <AppleBundleIdentifierDto>[
      for (final item in await _collection('/v1/bundleIds?$query')) _bundleIdentifier(item),
    ];
  }

  @override
  Future<List<AppleProvisioningProfileDto>> listAppStoreProfiles() async {
    final query = Uri(
      queryParameters: <String, String>{
        'filter[profileType]': 'IOS_APP_STORE',
        'fields[profiles]':
            'name,profileType,profileState,profileContent,uuid,createdDate,'
            'expirationDate,bundleId,certificates',
        'limit': '200',
      },
    ).query;
    return <AppleProvisioningProfileDto>[
      for (final item in await _collection('/v1/profiles?$query')) _provisioningProfile(item),
    ];
  }

  @override
  Future<AppleProvisioningProfileDto> createAppStoreProfile({
    required String name,
    required String bundleIdId,
    required String certificateId,
  }) async {
    final response = _map(
      await _request(
        'POST',
        '/v1/profiles',
        body: <String, Object?>{
          'data': <String, Object?>{
            'type': 'profiles',
            'attributes': <String, Object?>{
              'name': name,
              'profileType': 'IOS_APP_STORE',
            },
            'relationships': <String, Object?>{
              'bundleId': <String, Object?>{
                'data': <String, Object?>{
                  'type': 'bundleIds',
                  'id': bundleIdId,
                },
              },
              'certificates': <String, Object?>{
                'data': <Object?>[
                  <String, Object?>{
                    'type': 'certificates',
                    'id': certificateId,
                  },
                ],
              },
            },
          },
        },
      ),
      'profile',
    );
    return _provisioningProfile(response['data']);
  }

  Future<List<ApiResourceDto<PrereleaseVersionAttributesDto>>> listPrereleaseVersions(
    String appId, {
    String? version,
  }) async {
    final parameters = <String, String>{
      'filter[app]': appId,
      'filter[platform]': 'IOS',
      'limit': '200',
      'filter[version]': ?version,
    };
    final query = Uri(queryParameters: parameters).query;
    return <ApiResourceDto<PrereleaseVersionAttributesDto>>[
      for (final item in await _collection('/v1/preReleaseVersions?$query')) _prereleaseResource(item),
    ];
  }

  Future<List<ApiResourceDto<BuildAttributesDto>>> listBuildsForPrereleaseVersion(
    String prereleaseVersionId,
  ) async => <ApiResourceDto<BuildAttributesDto>>[
    for (final item in await _collection(
      '/v1/preReleaseVersions/$prereleaseVersionId/builds?limit=200',
    ))
      _buildResource(item),
  ];

  @override
  Future<List<ApiResourceDto<BuildAttributesDto>>> buildsForVersion({
    required String appId,
    required String version,
  }) async {
    final versions = await listPrereleaseVersions(appId, version: version);
    final matching = versions
        .where(
          (item) => item.attributes.version == version && item.attributes.platform == ApplePlatform.ios,
        )
        .firstOrNull;
    return matching == null
        ? const <ApiResourceDto<BuildAttributesDto>>[]
        : listBuildsForPrereleaseVersion(matching.id);
  }

  @override
  Future<String> nextBuildNumber({
    required String appId,
    required String version,
  }) async {
    final builds = await buildsForVersion(appId: appId, version: version);
    var latestMajor = BigInt.zero;
    for (final build in builds) {
      final value = build.attributes.version;
      final match = RegExp(
        r'^([0-9]+)(?:\.[0-9]+){0,2}$',
      ).firstMatch(value);
      if (match == null) {
        throw SmfError(
          'App Store Connect returned unsupported build number "$value".',
          SmfErrorCode.appStoreConnectResponse,
        );
      }
      final majorValue = match.group(1);
      if (majorValue == null) {
        throw SmfError(
          'App Store Connect returned unsupported build number "$value".',
          SmfErrorCode.appStoreConnectResponse,
        );
      }
      final major = BigInt.parse(majorValue);
      if (major > latestMajor) latestMajor = major;
    }
    return '${latestMajor + BigInt.one}';
  }

  @override
  Future<ApiResourceDto<BuildAttributesDto>> waitForBuild({
    required String appId,
    required String version,
    required String buildNumber,
    required int timeoutMinutes,
    Duration interval = const Duration(seconds: 30),
  }) async {
    final deadline = _currentTime().add(Duration(minutes: timeoutMinutes));
    while (_currentTime().isBefore(deadline)) {
      final builds = await buildsForVersion(appId: appId, version: version);
      final build = builds
          .where(
            (item) => item.attributes.version == buildNumber,
          )
          .firstOrNull;
      if (build case final build?) {
        if (build.attributes.processingState == BuildProcessingState.valid) {
          return build;
        }
        if (build.attributes.processingState case BuildProcessingState.failed || BuildProcessingState.invalid) {
          throw SmfError(
            'Apple marked $version ($buildNumber) as '
            '${build.attributes.processingState.value}.',
            SmfErrorCode.buildInvalid,
          );
        }
      }
      if (interval > Duration.zero) await _delay(interval);
    }
    throw SmfError(
      'Timed out waiting for $version ($buildNumber) to finish processing.',
      SmfErrorCode.buildTimeout,
    );
  }

  @override
  Future<void> setBetaBuildLocalization({
    required String buildId,
    required String locale,
    required String whatsNew,
  }) async {
    final localizations = await _collection(
      '/v1/builds/$buildId/betaBuildLocalizations?limit=200',
    );
    final existing = localizations
        .map(_genericResource)
        .where(
          (item) => item.attributes['locale'] == locale,
        )
        .firstOrNull;
    if (existing != null) {
      await _request(
        'PATCH',
        '/v1/betaBuildLocalizations/${existing.id}',
        body: <String, Object?>{
          'data': <String, Object?>{
            'type': 'betaBuildLocalizations',
            'id': existing.id,
            'attributes': <String, Object?>{'whatsNew': whatsNew},
          },
        },
      );
    } else {
      await _request(
        'POST',
        '/v1/betaBuildLocalizations',
        body: <String, Object?>{
          'data': <String, Object?>{
            'type': 'betaBuildLocalizations',
            'attributes': <String, Object?>{
              'locale': locale,
              'whatsNew': whatsNew,
            },
            'relationships': <String, Object?>{
              'build': <String, Object?>{
                'data': <String, Object?>{'type': 'builds', 'id': buildId},
              },
            },
          },
        },
      );
    }
  }

  @override
  Future<void> addBuildToGroups({
    required String appId,
    required String buildId,
    required List<String> names,
    required bool isInternal,
  }) async {
    if (names.isEmpty) return;
    final query = Uri(
      queryParameters: <String, String>{'filter[app]': appId, 'limit': '200'},
    ).query;
    final groups = (await _collection(
      '/v1/betaGroups?$query',
    )).map(_genericResource).toList();
    for (final name in names) {
      final group = groups
          .where(
            (item) => item.attributes['name'] == name,
          )
          .firstOrNull;
      if (group == null) {
        throw SmfError(
          'TestFlight group "$name" was not found for this app.',
          SmfErrorCode.betaGroupNotFound,
        );
      }
      final isInternalGroup = group.attributes['isInternalGroup'];
      SmfError.check(
        isInternalGroup is bool,
        'App Store Connect did not identify the audience for TestFlight group '
        '"$name".',
        SmfErrorCode.betaGroupInvalid,
      );
      SmfError.check(
        isInternalGroup == isInternal,
        'TestFlight group "$name" does not match the configured '
        '${isInternal ? 'internal-testing' : 'external-testing'} target.',
        SmfErrorCode.betaGroupAudienceMismatch,
      );
      final linked = (await _collection(
        '/v1/betaGroups/${group.id}/relationships/builds?limit=200',
      )).map(_mapResourceIdentifier);
      if (linked.any((item) => item.id == buildId)) {
        continue;
      }
      await _request(
        'POST',
        '/v1/betaGroups/${group.id}/relationships/builds',
        body: <String, Object?>{
          'data': <Object?>[
            <String, Object?>{'type': 'builds', 'id': buildId},
          ],
        },
      );
    }
  }

  @override
  Future<String> submitBuildForBetaReview(String buildId) async {
    final query = Uri(
      queryParameters: <String, String>{
        'filter[build]': buildId,
        'limit': '200',
      },
    ).query;
    final existing = (await _collection(
      '/v1/betaAppReviewSubmissions?$query',
    )).map(_genericResource);
    for (final submission in existing) {
      final state = BetaReviewState.parse(
        submission.attributes['betaReviewState'],
      );
      switch (state) {
        case BetaReviewState.waitingForReview:
        case BetaReviewState.inReview:
        case BetaReviewState.approved:
          return submission.id;
        case BetaReviewState.rejected:
          throw const SmfError(
            'Apple rejected this build for external TestFlight testing. '
            'Upload a new build before retrying.',
            SmfErrorCode.betaReviewRejected,
          );
      }
    }

    final created = _map(
      await _request(
        'POST',
        '/v1/betaAppReviewSubmissions',
        body: <String, Object?>{
          'data': <String, Object?>{
            'type': 'betaAppReviewSubmissions',
            'relationships': <String, Object?>{
              'build': <String, Object?>{
                'data': <String, Object?>{
                  'type': 'builds',
                  'id': buildId,
                },
              },
            },
          },
        },
      ),
      'beta app review submission',
    );
    return _string(
      _map(created['data'], 'beta app review submission.data')['id'],
      'beta app review submission.data.id',
    );
  }

  @override
  Future<ApiResourceDto<AppStoreVersionAttributesDto>> findOrCreateAppStoreVersion({
    required String appId,
    required String version,
    required bool shouldReleaseAutomatically,
  }) async {
    final desiredReleaseType = shouldReleaseAutomatically
        ? AppStoreReleaseType.afterApproval
        : AppStoreReleaseType.manual;
    final query = Uri(
      queryParameters: <String, String>{
        'filter[platform]': 'IOS',
        'filter[versionString]': version,
        'limit': '10',
      },
    ).query;
    final existing = <ApiResourceDto<AppStoreVersionAttributesDto>>[
      for (final item in await _collection(
        '/v1/apps/$appId/appStoreVersions?$query',
      ))
        _appStoreVersionResource(item),
    ];
    final match = existing
        .where(
          (item) => item.attributes.versionString == version,
        )
        .firstOrNull;
    if (match != null) {
      if (match.attributes.releaseType != desiredReleaseType) {
        SmfError.check(
          match.attributes.appVersionState.isEditable,
          'App Store version $version is already '
          '${match.attributes.appVersionState.name}; its release policy '
          'can no '
          'longer be changed.',
          SmfErrorCode.appStoreReleasePolicyLocked,
        );
        final updated = _map(
          await _request(
            'PATCH',
            '/v1/appStoreVersions/${match.id}',
            body: <String, Object?>{
              'data': <String, Object?>{
                'type': 'appStoreVersions',
                'id': match.id,
                'attributes': <String, Object?>{
                  'releaseType': desiredReleaseType.value,
                },
              },
            },
          ),
          'appStoreVersion',
        );
        return _appStoreVersionResource(updated['data']);
      }
      return match;
    }
    final created = _map(
      await _request(
        'POST',
        '/v1/appStoreVersions',
        body: <String, Object?>{
          'data': <String, Object?>{
            'type': 'appStoreVersions',
            'attributes': <String, Object?>{
              'platform': 'IOS',
              'versionString': version,
              'releaseType': desiredReleaseType.value,
            },
            'relationships': <String, Object?>{
              'app': <String, Object?>{
                'data': <String, Object?>{'type': 'apps', 'id': appId},
              },
            },
          },
        },
      ),
      'appStoreVersion',
    );
    return _appStoreVersionResource(created['data']);
  }

  @override
  Future<void> attachBuildToVersion({
    required String appStoreVersionId,
    required String buildId,
  }) async {
    await _request(
      'PATCH',
      '/v1/appStoreVersions/$appStoreVersionId/relationships/build',
      body: <String, Object?>{
        'data': <String, Object?>{'type': 'builds', 'id': buildId},
      },
    );
  }

  @override
  Future<String?> appStoreVersionBuildId(String appStoreVersionId) async {
    final response = _map(
      await _request(
        'GET',
        '/v1/appStoreVersions/$appStoreVersionId/relationships/build',
      ),
      'appStoreVersion build',
    );
    final data = response['data'];
    return data == null ? null : _mapResourceIdentifier(data).id;
  }

  @override
  Future<void> setAppStoreReleaseNotes({
    required String appStoreVersionId,
    required String locale,
    required String whatsNew,
  }) async {
    final localizations = (await _collection(
      '/v1/appStoreVersions/$appStoreVersionId/'
      'appStoreVersionLocalizations?limit=200',
    )).map(_genericResource);
    final localization = localizations
        .where(
          (item) => item.attributes['locale'] == locale,
        )
        .firstOrNull;
    if (localization == null) {
      throw SmfError(
        'App Store locale "$locale" does not exist. Add it to the app in App '
        'Store Connect before releasing.',
        SmfErrorCode.appStoreLocaleNotFound,
      );
    }
    await _request(
      'PATCH',
      '/v1/appStoreVersionLocalizations/${localization.id}',
      body: <String, Object?>{
        'data': <String, Object?>{
          'type': 'appStoreVersionLocalizations',
          'id': localization.id,
          'attributes': <String, Object?>{'whatsNew': whatsNew},
        },
      },
    );
  }

  @override
  Future<String> submitVersionForReview({
    required String appId,
    required String appStoreVersionId,
  }) async {
    final submissions =
        <ReviewSubmissionDto>[
          for (final item in await _collection(
            '/v1/apps/$appId/reviewSubmissions?'
            'filter%5Bplatform%5D=IOS&'
            'include=appStoreVersionForReview&limit=200',
          ))
            _reviewSubmission(item),
        ].where(
          (submission) => submission.appStoreVersionId == appStoreVersionId,
        );
    ReviewSubmissionDto? completed;
    for (final submission in submissions) {
      switch (submission.state) {
        case ReviewSubmissionState.readyForReview:
          await _submitReviewSubmission(submission.id);
          return submission.id;
        case ReviewSubmissionState.waitingForReview:
        case ReviewSubmissionState.inReview:
        case ReviewSubmissionState.completing:
          return submission.id;
        case ReviewSubmissionState.complete:
          completed ??= submission;
        case ReviewSubmissionState.unresolvedIssues:
          throw const SmfError(
            'App Review reported unresolved issues. Resolve them in App Store '
            'Connect before retrying.',
            SmfErrorCode.appReviewUnresolved,
          );
        case ReviewSubmissionState.canceling:
          throw const SmfError(
            'The App Store review submission is still canceling. Wait for '
            'Apple to finish before retrying.',
            SmfErrorCode.appReviewCanceling,
          );
      }
    }
    if (completed != null) return completed.id;

    final created = _map(
      await _request(
        'POST',
        '/v1/reviewSubmissions',
        body: <String, Object?>{
          'data': <String, Object?>{
            'type': 'reviewSubmissions',
            'relationships': <String, Object?>{
              'app': <String, Object?>{
                'data': <String, Object?>{'type': 'apps', 'id': appId},
              },
            },
          },
        },
      ),
      'review submission',
    );
    final submission = _map(created['data'], 'review submission.data');
    final submissionId = _string(submission['id'], 'review submission.id');
    await _request(
      'POST',
      '/v1/reviewSubmissionItems',
      body: <String, Object?>{
        'data': <String, Object?>{
          'type': 'reviewSubmissionItems',
          'relationships': <String, Object?>{
            'reviewSubmission': <String, Object?>{
              'data': <String, Object?>{
                'type': 'reviewSubmissions',
                'id': submissionId,
              },
            },
            'appStoreVersion': <String, Object?>{
              'data': <String, Object?>{
                'type': 'appStoreVersions',
                'id': appStoreVersionId,
              },
            },
          },
        },
      },
    );
    await _submitReviewSubmission(submissionId);
    return submissionId;
  }

  Future<void> _submitReviewSubmission(String submissionId) async {
    await _request(
      'PATCH',
      '/v1/reviewSubmissions/$submissionId',
      body: <String, Object?>{
        'data': <String, Object?>{
          'type': 'reviewSubmissions',
          'id': submissionId,
          'attributes': <String, Object?>{'isSubmitted': true},
        },
      },
    );
  }

  ReviewSubmissionDto _reviewSubmission(Object? value) {
    final submission = _map(value, 'review submission');
    final attributes = _map(
      submission['attributes'],
      'review submission.attributes',
    );
    return ReviewSubmissionDto(
      id: _string(submission['id'], 'review submission.id'),
      state: ReviewSubmissionState.parse(attributes['state']),
      appStoreVersionId: _reviewSubmissionVersionId(submission),
    );
  }

  String? _reviewSubmissionVersionId(Map<String, Object?> submission) {
    final relationshipsValue = submission['relationships'];
    if (relationshipsValue == null) return null;
    final relationships = _map(
      relationshipsValue,
      'review submission.relationships',
    );
    final versionValue = relationships['appStoreVersionForReview'];
    if (versionValue == null) return null;
    final version = _map(
      versionValue,
      'review submission.relationships.appStoreVersionForReview',
    );
    final dataValue = version['data'];
    if (dataValue == null) return null;
    final data = _map(
      dataValue,
      'review submission.relationships.appStoreVersionForReview.data',
    );
    return _optionalString(
      data['id'],
      'review submission.relationships.appStoreVersionForReview.data.id',
    );
  }

  ApiResourceDto<AppAttributesDto> _appResource(Object? value) {
    return _resource(
      value,
      path: 'app',
      attributesFromJson: AppAttributesDto.fromJson,
    );
  }

  ApiResourceDto<PrereleaseVersionAttributesDto> _prereleaseResource(Object? value) {
    return _resource(
      value,
      path: 'preReleaseVersion',
      attributesFromJson: PrereleaseVersionAttributesDto.fromJson,
    );
  }

  ApiResourceDto<BuildAttributesDto> _buildResource(Object? value) {
    return _resource(
      value,
      path: 'build',
      attributesFromJson: BuildAttributesDto.fromJson,
    );
  }

  ApiResourceDto<AppStoreVersionAttributesDto> _appStoreVersionResource(
    Object? value,
  ) {
    return _resource(
      value,
      path: 'appStoreVersion',
      attributesFromJson: AppStoreVersionAttributesDto.fromJson,
    );
  }

  AppleSigningCertificateDto _signingCertificate(Object? value) {
    final resource = _map(value, 'certificate');
    final attributes = _map(
      resource['attributes'],
      'certificate.attributes',
    );
    return AppleSigningCertificateDto(
      id: _string(resource['id'], 'certificate.id'),
      certificateType: _string(
        attributes['certificateType'],
        'certificate.attributes.certificateType',
      ),
      displayName: _string(
        attributes['displayName'],
        'certificate.attributes.displayName',
      ),
      serialNumber: _string(
        attributes['serialNumber'],
        'certificate.attributes.serialNumber',
      ),
      certificateContent: _string(
        attributes['certificateContent'],
        'certificate.attributes.certificateContent',
      ),
      expirationDate: _dateTime(
        attributes['expirationDate'],
        'certificate.attributes.expirationDate',
      ),
      isActivated: _boolean(
        attributes['activated'],
        'certificate.attributes.activated',
      ),
    );
  }

  AppleBundleIdentifierDto _bundleIdentifier(Object? value) {
    final resource = _map(value, 'bundleId');
    final attributes = _map(resource['attributes'], 'bundleId.attributes');
    return AppleBundleIdentifierDto(
      id: _string(resource['id'], 'bundleId.id'),
      identifier: _string(
        attributes['identifier'],
        'bundleId.attributes.identifier',
      ),
      platform: _string(
        attributes['platform'],
        'bundleId.attributes.platform',
      ),
    );
  }

  AppleProvisioningProfileDto _provisioningProfile(Object? value) {
    final resource = _map(value, 'profile');
    final attributes = _map(resource['attributes'], 'profile.attributes');
    final relationships = _map(
      resource['relationships'],
      'profile.relationships',
    );
    final bundleRelationship = _map(
      relationships['bundleId'],
      'profile.relationships.bundleId',
    );
    final certificateRelationship = _map(
      relationships['certificates'],
      'profile.relationships.certificates',
    );
    final bundleId = _mapResourceIdentifier(bundleRelationship['data']);
    final certificateIds = <String>[
      for (final item in _list(
        certificateRelationship['data'],
        'profile.relationships.certificates.data',
      ))
        _mapResourceIdentifier(item).id,
    ];
    return AppleProvisioningProfileDto(
      id: _string(resource['id'], 'profile.id'),
      name: _string(attributes['name'], 'profile.attributes.name'),
      profileType: _string(
        attributes['profileType'],
        'profile.attributes.profileType',
      ),
      profileState: _string(
        attributes['profileState'],
        'profile.attributes.profileState',
      ),
      profileContent: _string(
        attributes['profileContent'],
        'profile.attributes.profileContent',
      ),
      uuid: _string(attributes['uuid'], 'profile.attributes.uuid'),
      createdDate: _dateTime(
        attributes['createdDate'],
        'profile.attributes.createdDate',
      ),
      expirationDate: _dateTime(
        attributes['expirationDate'],
        'profile.attributes.expirationDate',
      ),
      bundleIdId: bundleId.id,
      certificateIds: certificateIds,
    );
  }

  ApiResourceDto<Map<String, Object?>> _genericResource(Object? value) {
    return _resource(
      value,
      path: 'resource',
      attributesFromJson: (json) => json,
    );
  }

  ApiResourceDto<T> _resource<T>(
    Object? value, {
    required String path,
    required T Function(Map<String, Object?>) attributesFromJson,
  }) {
    try {
      return ApiResourceDto<T>.fromJson(
        _map(value, path),
        (attributes) => attributesFromJson(_map(attributes, '$path.attributes')),
      );
    } on CheckedFromJsonException catch (error) {
      throw SmfError(
        '$path contains invalid response data.',
        SmfErrorCode.appStoreConnectResponse,
        cause: error,
      );
    }
  }

  ({String type, String id}) _mapResourceIdentifier(Object? value) {
    final resource = _map(value, 'resource identifier');
    return (
      type: _string(resource['type'], 'resource identifier.type'),
      id: _string(resource['id'], 'resource identifier.id'),
    );
  }

  Map<String, Object?> _map(Object? value, String path) {
    if (value is! Map<Object?, Object?>) {
      throw SmfError('$path must be an object.', SmfErrorCode.appStoreConnectResponse);
    }
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw SmfError(
          '$path contains a non-string key.',
          SmfErrorCode.appStoreConnectResponse,
        );
      }
      result[key] = entry.value;
    }
    return result;
  }

  List<Object?> _list(Object? value, String path) {
    if (value is! List<Object?>) {
      throw SmfError('$path must be a list.', SmfErrorCode.appStoreConnectResponse);
    }
    return value;
  }

  String _string(Object? value, String path) {
    if (value is! String) {
      throw SmfError('$path must be a string.', SmfErrorCode.appStoreConnectResponse);
    }
    return value;
  }

  String? _optionalString(Object? value, String path) {
    if (value == null) return null;
    return _string(value, path);
  }

  bool _boolean(Object? value, String path) {
    if (value is! bool) {
      throw SmfError('$path must be a boolean.', SmfErrorCode.appStoreConnectResponse);
    }
    return value;
  }

  DateTime _dateTime(Object? value, String path) {
    final parsed = DateTime.tryParse(_string(value, path));
    if (parsed == null) {
      throw SmfError(
        '$path must be an ISO-8601 date-time.',
        SmfErrorCode.appStoreConnectResponse,
      );
    }
    return parsed.toUtc();
  }

  Object? _decodeResponseBody(String body) {
    try {
      return jsonDecode(body);
    } on FormatException catch (error) {
      throw SmfError(
        'App Store Connect returned malformed JSON.',
        SmfErrorCode.appStoreConnectResponse,
        cause: error,
      );
    }
  }
}
