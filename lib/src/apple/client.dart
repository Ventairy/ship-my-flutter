import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;

import '../error.dart';
import '../model.dart';

final class ApiResource<T> {
  const ApiResource({
    required this.type,
    required this.id,
    required this.attributes,
  });

  final String type;
  final String id;
  final T attributes;
}

final class AppAttributes {
  const AppAttributes({
    required this.name,
    required this.bundleId,
    required this.sku,
    required this.primaryLocale,
  });

  final String name;
  final String bundleId;
  final String sku;
  final String primaryLocale;
}

final class BuildAttributes {
  const BuildAttributes({
    required this.version,
    required this.processingState,
    this.uploadedDate,
    this.expired = false,
    this.usesNonExemptEncryption,
  });

  final String version;
  final String? uploadedDate;
  final String processingState;
  final bool expired;
  final bool? usesNonExemptEncryption;
}

final class PrereleaseVersionAttributes {
  const PrereleaseVersionAttributes({
    required this.version,
    required this.platform,
  });

  final String version;
  final String platform;
}

final class AppStoreVersionAttributes {
  const AppStoreVersionAttributes({
    required this.platform,
    required this.versionString,
    required this.appStoreState,
    required this.releaseType,
    this.earliestReleaseDate,
  });

  final String platform;
  final String versionString;
  final String appStoreState;
  final String releaseType;
  final String? earliestReleaseDate;
}

abstract interface class AppStoreConnectApi {
  Future<ApiResource<AppAttributes>> findApp(String bundleId);

  Future<List<ApiResource<BuildAttributes>>> buildsForVersion(
    String appId,
    String version,
  );

  Future<ApiResource<BuildAttributes>> getBuild(String buildId);

  Future<String> nextBuildNumber(String appId, String version);

  Future<ApiResource<BuildAttributes>> waitForBuild(
    String appId,
    String version,
    String buildNumber,
    int timeoutMinutes, {
    Duration interval = const Duration(seconds: 30),
  });

  Future<void> setBetaBuildLocalization(
    String buildId,
    String locale,
    String whatsNew,
  );

  Future<void> addBuildToGroups(
    String appId,
    String buildId,
    List<String> names,
  );

  Future<ApiResource<AppStoreVersionAttributes>> findOrCreateAppStoreVersion(
    String appId,
    String version,
    StoreReleaseType releaseType, {
    DateTime? earliestReleaseDate,
  });

  Future<void> attachBuildToVersion(String appStoreVersionId, String buildId);

  Future<String?> appStoreVersionBuildId(String appStoreVersionId);

  Future<void> setAppStoreReleaseNotes(
    String appStoreVersionId,
    String locale,
    String whatsNew,
  );

  Future<String> submitVersionForReview(String appId, String appStoreVersionId);
}

typedef AppleTokenProvider = Future<String> Function();

DateTime _systemTime() => DateTime.now();

Future<void> _systemDelay(Duration duration) => Future<void>.delayed(duration);

final class AppStoreConnectClient implements AppStoreConnectApi {
  /// Creates an App Store Connect client.
  ///
  /// [currentTime] and [delay] are deterministic seams for build-processing
  /// polling. Normal consumers should leave them unset.
  AppStoreConnectClient(
    this.credentials, {
    http.Client? httpClient,
    AppleTokenProvider? tokenProvider,
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
  final AppleTokenProvider? _tokenProvider;
  final DateTime Function() _currentTime;
  final Future<void> Function(Duration) _delay;
  final Uri baseUrl;

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

  Future<Object?> request(String method, String path, {Object? body}) async {
    final url = baseUrl.resolve(path);
    invariant(
      url.origin == baseUrl.origin,
      'App Store Connect pagination returned an unexpected origin.',
      'APP_STORE_CONNECT_ORIGIN',
    );
    final request = http.Request(method, url)
      ..headers.addAll(<String, String>{
        'Authorization': 'Bearer ${await _token()}',
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json',
      });
    if (body != null) request.body = jsonEncode(body);
    late final http.Response response;
    try {
      final streamed = await _httpClient.send(request);
      response = await http.Response.fromStream(streamed);
    } on http.ClientException catch (error) {
      throw ShipError(
        'Could not reach App Store Connect.',
        'APP_STORE_CONNECT_API',
        cause: error,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String? details;
      try {
        final document = _map(jsonDecode(response.body), 'error document');
        final errors = document['errors'];
        if (errors is List<Object?>) {
          details = errors
              .map((Object? value) {
                final error = _map(value, 'error');
                return <Object?>[
                  error['code'],
                  error['title'],
                  error['detail'],
                ].whereType<String>().join(': ');
              })
              .where((String value) => value.isNotEmpty)
              .join('; ');
        }
      } on FormatException {
        details = null;
      } on ShipError {
        details = null;
      }
      final requestTarget = '${url.path}${url.hasQuery ? '?${url.query}' : ''}';
      throw ShipError(
        'App Store Connect $method $requestTarget '
            'failed (${response.statusCode})'
            '${details == null || details.isEmpty ? '' : ': $details'}',
        'APP_STORE_CONNECT_API',
      );
    }
    if (response.statusCode == 204 || response.body.isEmpty) return null;
    return _decodeResponseBody(response.body);
  }

  Future<List<Object?>> _collection(String path) async {
    final data = <Object?>[];
    final seen = <String>{};
    String? next = path;
    while (next != null) {
      invariant(
        seen.add(next),
        'App Store Connect returned a pagination loop.',
        'APP_STORE_CONNECT_PAGINATION',
      );
      final page = _map(await request('GET', next), 'collection');
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
  Future<ApiResource<AppAttributes>> findApp(String bundleId) async {
    final query = Uri(
      queryParameters: <String, String>{'filter[bundleId]': bundleId},
    ).query;
    final response = _map(await request('GET', '/v1/apps?$query'), 'apps');
    final data = _list(response['data'], 'apps.data');
    invariant(
      data.length == 1,
      data.isEmpty
          ? 'No App Store Connect app found for $bundleId'
          : 'Multiple App Store Connect apps found for $bundleId',
      'APP_NOT_FOUND',
    );
    return _appResource(data.single);
  }

  Future<List<ApiResource<PrereleaseVersionAttributes>>> listPrereleaseVersions(
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
    return <ApiResource<PrereleaseVersionAttributes>>[
      for (final item in await _collection('/v1/preReleaseVersions?$query'))
        _prereleaseResource(item),
    ];
  }

  Future<List<ApiResource<BuildAttributes>>> listBuildsForPrereleaseVersion(
    String prereleaseVersionId,
  ) async => <ApiResource<BuildAttributes>>[
    for (final item in await _collection(
      '/v1/preReleaseVersions/$prereleaseVersionId/builds?limit=200',
    ))
      _buildResource(item),
  ];

  @override
  Future<List<ApiResource<BuildAttributes>>> buildsForVersion(
    String appId,
    String version,
  ) async {
    final versions = await listPrereleaseVersions(appId, version: version);
    final matching = versions
        .where(
          (ApiResource<PrereleaseVersionAttributes> item) =>
              item.attributes.version == version &&
              item.attributes.platform == 'IOS',
        )
        .firstOrNull;
    return matching == null
        ? const <ApiResource<BuildAttributes>>[]
        : listBuildsForPrereleaseVersion(matching.id);
  }

  @override
  Future<ApiResource<BuildAttributes>> getBuild(String buildId) async {
    final response = _map(await request('GET', '/v1/builds/$buildId'), 'build');
    return _buildResource(response['data']);
  }

  @override
  Future<String> nextBuildNumber(String appId, String version) async {
    final builds = await buildsForVersion(appId, version);
    final numeric = builds.map((ApiResource<BuildAttributes> build) {
      return int.tryParse(build.attributes.version);
    }).whereType<int>();
    final latest = numeric.isEmpty
        ? 0
        : numeric.reduce(
            (int first, int second) => first > second ? first : second,
          );
    return '${latest + 1}';
  }

  @override
  Future<ApiResource<BuildAttributes>> waitForBuild(
    String appId,
    String version,
    String buildNumber,
    int timeoutMinutes, {
    Duration interval = const Duration(seconds: 30),
  }) async {
    final deadline = _currentTime().add(Duration(minutes: timeoutMinutes));
    while (_currentTime().isBefore(deadline)) {
      final builds = await buildsForVersion(appId, version);
      final build = builds
          .where(
            (ApiResource<BuildAttributes> item) =>
                item.attributes.version == buildNumber,
          )
          .firstOrNull;
      if (build?.attributes.processingState == 'VALID') return build!;
      if (<String>{
        'FAILED',
        'INVALID',
      }.contains(build?.attributes.processingState)) {
        throw ShipError(
          'Apple marked $version ($buildNumber) as '
              '${build?.attributes.processingState}.',
          'BUILD_INVALID',
        );
      }
      if (interval > Duration.zero) await _delay(interval);
    }
    throw ShipError(
      'Timed out waiting for $version ($buildNumber) to finish processing.',
      'BUILD_TIMEOUT',
    );
  }

  @override
  Future<void> setBetaBuildLocalization(
    String buildId,
    String locale,
    String whatsNew,
  ) async {
    final localizations = await _collection(
      '/v1/builds/$buildId/betaBuildLocalizations?limit=200',
    );
    final existing = localizations
        .map(_genericResource)
        .where(
          (ApiResource<Map<String, Object?>> item) =>
              item.attributes['locale'] == locale,
        )
        .firstOrNull;
    if (existing != null) {
      await request(
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
      await request(
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
  Future<void> addBuildToGroups(
    String appId,
    String buildId,
    List<String> names,
  ) async {
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
            (ApiResource<Map<String, Object?>> item) =>
                item.attributes['name'] == name,
          )
          .firstOrNull;
      invariant(
        group != null,
        'TestFlight group "$name" was not found for this app.',
        'BETA_GROUP_NOT_FOUND',
      );
      final linked = (await _collection(
        '/v1/betaGroups/${group!.id}/relationships/builds?limit=200',
      )).map(_mapResourceIdentifier);
      if (linked.any((item) => item.id == buildId)) {
        continue;
      }
      await request(
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
  Future<ApiResource<AppStoreVersionAttributes>> findOrCreateAppStoreVersion(
    String appId,
    String version,
    StoreReleaseType releaseType, {
    DateTime? earliestReleaseDate,
  }) async {
    invariant(
      releaseType != StoreReleaseType.scheduled || earliestReleaseDate != null,
      'earliestReleaseDate is required for a scheduled App Store release.',
      'SCHEDULED_RELEASE_DATE',
    );
    final desiredReleaseType = switch (releaseType) {
      StoreReleaseType.manual => 'MANUAL',
      StoreReleaseType.automatic => 'AFTER_APPROVAL',
      StoreReleaseType.scheduled => 'SCHEDULED',
    };
    final query = Uri(
      queryParameters: <String, String>{
        'filter[platform]': 'IOS',
        'filter[versionString]': version,
        'limit': '10',
      },
    ).query;
    final existing = <ApiResource<AppStoreVersionAttributes>>[
      for (final item in await _collection(
        '/v1/apps/$appId/appStoreVersions?$query',
      ))
        _appStoreVersionResource(item),
    ];
    final match = existing
        .where(
          (ApiResource<AppStoreVersionAttributes> item) =>
              item.attributes.versionString == version,
        )
        .firstOrNull;
    final earliestIso = earliestReleaseDate?.toUtc().toIso8601String();
    if (match != null) {
      final existingDate = match.attributes.earliestReleaseDate;
      final releasePolicyChanged =
          match.attributes.releaseType != desiredReleaseType ||
          (releaseType == StoreReleaseType.scheduled &&
              DateTime.tryParse(existingDate ?? '')?.toUtc() !=
                  earliestReleaseDate?.toUtc());
      if (releasePolicyChanged) {
        invariant(
          match.attributes.appStoreState == 'PREPARE_FOR_SUBMISSION',
          'App Store version $version is already '
              '${match.attributes.appStoreState}; its release policy can no '
              'longer be changed.',
          'APP_STORE_RELEASE_POLICY_LOCKED',
        );
        final updated = _map(
          await request(
            'PATCH',
            '/v1/appStoreVersions/${match.id}',
            body: <String, Object?>{
              'data': <String, Object?>{
                'type': 'appStoreVersions',
                'id': match.id,
                'attributes': <String, Object?>{
                  'releaseType': desiredReleaseType,
                  'earliestReleaseDate': ?earliestIso,
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
      await request(
        'POST',
        '/v1/appStoreVersions',
        body: <String, Object?>{
          'data': <String, Object?>{
            'type': 'appStoreVersions',
            'attributes': <String, Object?>{
              'platform': 'IOS',
              'versionString': version,
              'releaseType': desiredReleaseType,
              'earliestReleaseDate': ?earliestIso,
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
  Future<void> attachBuildToVersion(
    String appStoreVersionId,
    String buildId,
  ) async {
    await request(
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
      await request(
        'GET',
        '/v1/appStoreVersions/$appStoreVersionId/relationships/build',
      ),
      'appStoreVersion build',
    );
    final data = response['data'];
    return data == null ? null : _mapResourceIdentifier(data).id;
  }

  @override
  Future<void> setAppStoreReleaseNotes(
    String appStoreVersionId,
    String locale,
    String whatsNew,
  ) async {
    final localizations = (await _collection(
      '/v1/appStoreVersions/$appStoreVersionId/'
      'appStoreVersionLocalizations?limit=200',
    )).map(_genericResource);
    final localization = localizations
        .where(
          (ApiResource<Map<String, Object?>> item) =>
              item.attributes['locale'] == locale,
        )
        .firstOrNull;
    invariant(
      localization != null,
      'App Store locale "$locale" does not exist. Add it to the app in App '
          'Store Connect before releasing.',
      'APP_STORE_LOCALE_NOT_FOUND',
    );
    await request(
      'PATCH',
      '/v1/appStoreVersionLocalizations/${localization!.id}',
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
  Future<String> submitVersionForReview(
    String appId,
    String appStoreVersionId,
  ) async {
    final active = _map(
      await request(
        'GET',
        '/v1/apps/$appId/reviewSubmissions?'
            'filter%5Bplatform%5D=IOS&'
            'include=appStoreVersionForReview&limit=200',
      ),
      'review submissions',
    );
    const activeStates = <String>{
      'READY_FOR_REVIEW',
      'WAITING_FOR_REVIEW',
      'IN_REVIEW',
      'UNRESOLVED_ISSUES',
    };
    for (final item in _list(active['data'], 'review submissions.data')) {
      final submission = _map(item, 'review submission');
      final attributes = _map(
        submission['attributes'],
        'review submission.attributes',
      );
      final relationshipId = _reviewSubmissionVersionId(submission);
      final state = _string(
        attributes['state'],
        'review submission.attributes.state',
      );
      if (relationshipId == appStoreVersionId && activeStates.contains(state)) {
        return _string(submission['id'], 'review submission.id');
      }
    }

    final created = _map(
      await request(
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
    await request(
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
    await request(
      'PATCH',
      '/v1/reviewSubmissions/$submissionId',
      body: <String, Object?>{
        'data': <String, Object?>{
          'type': 'reviewSubmissions',
          'id': submissionId,
          'attributes': <String, Object?>{'submitted': true},
        },
      },
    );
    return submissionId;
  }
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

ApiResource<AppAttributes> _appResource(Object? value) {
  final resource = _map(value, 'app');
  final attributes = _map(resource['attributes'], 'app.attributes');
  return ApiResource<AppAttributes>(
    type: _string(resource['type'], 'app.type'),
    id: _string(resource['id'], 'app.id'),
    attributes: AppAttributes(
      name: _string(attributes['name'], 'app.name'),
      bundleId: _string(attributes['bundleId'], 'app.bundleId'),
      sku: _string(attributes['sku'], 'app.sku'),
      primaryLocale: _string(attributes['primaryLocale'], 'app.primaryLocale'),
    ),
  );
}

ApiResource<PrereleaseVersionAttributes> _prereleaseResource(Object? value) {
  final resource = _map(value, 'preReleaseVersion');
  final attributes = _map(
    resource['attributes'],
    'preReleaseVersion.attributes',
  );
  return ApiResource<PrereleaseVersionAttributes>(
    type: _string(resource['type'], 'preReleaseVersion.type'),
    id: _string(resource['id'], 'preReleaseVersion.id'),
    attributes: PrereleaseVersionAttributes(
      version: _string(attributes['version'], 'preReleaseVersion.version'),
      platform: _string(attributes['platform'], 'preReleaseVersion.platform'),
    ),
  );
}

ApiResource<BuildAttributes> _buildResource(Object? value) {
  final resource = _map(value, 'build');
  final attributes = _map(resource['attributes'], 'build.attributes');
  return ApiResource<BuildAttributes>(
    type: _string(resource['type'], 'build.type'),
    id: _string(resource['id'], 'build.id'),
    attributes: BuildAttributes(
      version: _string(attributes['version'], 'build.version'),
      processingState: _string(
        attributes['processingState'],
        'build.processingState',
      ),
      uploadedDate: _optionalString(
        attributes['uploadedDate'],
        'build.uploadedDate',
      ),
      expired: _optionalBool(attributes['expired'], 'build.expired') ?? false,
      usesNonExemptEncryption: _optionalBool(
        attributes['usesNonExemptEncryption'],
        'build.usesNonExemptEncryption',
      ),
    ),
  );
}

ApiResource<AppStoreVersionAttributes> _appStoreVersionResource(Object? value) {
  final resource = _map(value, 'appStoreVersion');
  final attributes = _map(resource['attributes'], 'appStoreVersion.attributes');
  return ApiResource<AppStoreVersionAttributes>(
    type: _string(resource['type'], 'appStoreVersion.type'),
    id: _string(resource['id'], 'appStoreVersion.id'),
    attributes: AppStoreVersionAttributes(
      platform: _string(attributes['platform'], 'appStoreVersion.platform'),
      versionString: _string(
        attributes['versionString'],
        'appStoreVersion.versionString',
      ),
      appStoreState: _string(
        attributes['appStoreState'],
        'appStoreVersion.appStoreState',
      ),
      releaseType: _string(
        attributes['releaseType'],
        'appStoreVersion.releaseType',
      ),
      earliestReleaseDate: _optionalString(
        attributes['earliestReleaseDate'],
        'appStoreVersion.earliestReleaseDate',
      ),
    ),
  );
}

ApiResource<Map<String, Object?>> _genericResource(Object? value) {
  final resource = _map(value, 'resource');
  return ApiResource<Map<String, Object?>>(
    type: _string(resource['type'], 'resource.type'),
    id: _string(resource['id'], 'resource.id'),
    attributes: _map(resource['attributes'], 'resource.attributes'),
  );
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
    throw ShipError('$path must be an object.', 'APP_STORE_CONNECT_RESPONSE');
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      throw ShipError(
        '$path contains a non-string key.',
        'APP_STORE_CONNECT_RESPONSE',
      );
    }
    result[key] = entry.value;
  }
  return result;
}

List<Object?> _list(Object? value, String path) {
  if (value is! List<Object?>) {
    throw ShipError('$path must be a list.', 'APP_STORE_CONNECT_RESPONSE');
  }
  return value;
}

String _string(Object? value, String path) {
  if (value is! String) {
    throw ShipError('$path must be a string.', 'APP_STORE_CONNECT_RESPONSE');
  }
  return value;
}

String? _optionalString(Object? value, String path) {
  if (value == null) return null;
  return _string(value, path);
}

bool? _optionalBool(Object? value, String path) {
  if (value == null) return null;
  if (value is! bool) {
    throw ShipError('$path must be a boolean.', 'APP_STORE_CONNECT_RESPONSE');
  }
  return value;
}

Object? _decodeResponseBody(String body) {
  try {
    return jsonDecode(body);
  } on FormatException catch (error) {
    throw ShipError(
      'App Store Connect returned malformed JSON.',
      'APP_STORE_CONNECT_RESPONSE',
      cause: error,
    );
  }
}
