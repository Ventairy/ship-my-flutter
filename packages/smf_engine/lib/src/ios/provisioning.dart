import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smf_engine/smf_engine.dart';
import 'package:smf_engine/src/ios/client.dart';
import 'package:smf_engine/src/ios/models/resolved_signing_assets.dart';
import 'package:smf_engine/src/ios/models/signing_credentials.dart';

/// Resolves exact App Store profiles for signed application targets.
final class AppleProvisioning {
  const AppleProvisioning._();

  static const Set<String> _distributionCertificateTypes = <String>{
    'DISTRIBUTION',
    'IOS_DISTRIBUTION',
  };
  static const Duration _minimumSigningValidity = Duration(hours: 24);

  /// Finds or creates profiles through Apple's supported provisioning API.
  static Future<AppleResolvedSigningAssets> resolve({
    required AppleSigningCredentials credentials,
    required Set<String> bundleIds,
    required AppStoreConnectApi client,
    ProcessRunner processRunner = const SystemProcessRunner(),
    Directory? temporaryRoot,
    DateTime Function()? currentTime,
  }) async {
    SmfError.check(
      bundleIds.isNotEmpty,
      'No signed Apple bundle identifiers were discovered.',
      SmfErrorCode.appleSigningTargetsNotFound,
    );
    final now = (currentTime ?? DateTime.now)().toUtc();
    final validAfter = now.add(_minimumSigningValidity);
    final certificateDer = await _certificateDer(
      credentials,
      processRunner: processRunner,
      temporaryRoot: temporaryRoot,
    );
    final certificates = await client.listSigningCertificates();
    final contentMatches = certificates.where((certificate) {
      List<int> content;
      try {
        content = base64Decode(
          certificate.certificateContent.replaceAll(RegExp(r'\s'), ''),
        );
      } on FormatException catch (error) {
        throw SmfError(
          'Apple returned malformed distribution-certificate content.',
          SmfErrorCode.appStoreConnectResponse,
          cause: error,
        );
      }
      return _bytesEqual(certificateDer, content);
    }).toList();
    SmfError.check(
      contentMatches.length == 1,
      contentMatches.isEmpty
          ? 'The supplied .p12 certificate is not registered with this Apple '
                'developer team.'
          : 'Apple returned the supplied .p12 certificate more than once.',
      SmfErrorCode.appleCertificateNotFound,
    );
    final certificate = contentMatches.single;
    SmfError.check(
      _distributionCertificateTypes.contains(certificate.certificateType),
      'The supplied .p12 is ${certificate.certificateType}, not an Apple '
      'Distribution certificate.',
      SmfErrorCode.appleCertificateTypeMismatch,
    );
    SmfError.check(
      certificate.isActivated && certificate.expirationDate.isAfter(validAfter),
      'The supplied Apple Distribution certificate is inactive, expired, or '
      'expires within 24 hours.',
      SmfErrorCode.appleCertificateInvalid,
    );

    final registered = await client.listIosBundleIds();
    final bundleResources = <String, AppleBundleIdentifierDto>{};
    for (final bundleId in bundleIds) {
      final matches = registered
          .where(
            (resource) => resource.platform == 'IOS' && resource.identifier == bundleId,
          )
          .toList();
      SmfError.check(
        matches.length == 1,
        matches.isEmpty
            ? 'No registered iOS App ID matches $bundleId.'
            : 'Apple returned more than one iOS App ID for $bundleId.',
        SmfErrorCode.appleBundleIdNotFound,
      );
      bundleResources[bundleId] = matches.single;
    }

    final knownProfiles = List<AppleProvisioningProfileDto>.of(
      await client.listAppStoreProfiles(),
    );
    final knownNames = knownProfiles.map((profile) => profile.name).toSet();
    final encodedProfiles = <String, String>{};
    final sortedBundleResources = bundleResources.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));
    for (final bundleEntry in sortedBundleResources) {
      final bundleId = bundleEntry.key;
      final bundleResource = bundleEntry.value;
      var profile = _bestProfile(
        knownProfiles,
        bundleResource,
        certificate,
        validAfter,
      );
      if (profile == null) {
        final profileName = _availableProfileName(
          bundleId,
          certificate.serialNumber,
          knownNames,
        );
        knownNames.add(profileName);
        profile = await _createOrRecoverProfile(
          client: client,
          name: profileName,
          bundleId: bundleResource,
          certificate: certificate,
          validAfter: validAfter,
        );
        knownProfiles.add(profile);
      }
      _validateProfile(profile, bundleResource, certificate, validAfter);
      encodedProfiles[bundleId] = _normalizedBase64Profile(
        profile.profileContent,
        bundleId,
      );
    }

    return AppleResolvedSigningAssets(
      credentials: credentials,
      profilesByBundleId: Map<String, String>.unmodifiable(encodedProfiles),
    );
  }

  static AppleProvisioningProfileDto? _bestProfile(
    Iterable<AppleProvisioningProfileDto> profiles,
    AppleBundleIdentifierDto bundleId,
    AppleSigningCertificateDto certificate,
    DateTime validAfter,
  ) {
    final matches =
        profiles
            .where(
              (profile) =>
                  _profileMatches(
                    profile,
                    bundleId,
                    certificate,
                    validAfter,
                  ) &&
                  _isNonEmptyBase64(profile.profileContent),
            )
            .toList()
          ..sort((left, right) {
            final dateOrder = right.createdDate.compareTo(left.createdDate);
            return dateOrder != 0 ? dateOrder : left.id.compareTo(right.id);
          });
    return matches.firstOrNull;
  }

  static bool _profileMatches(
    AppleProvisioningProfileDto profile,
    AppleBundleIdentifierDto bundleId,
    AppleSigningCertificateDto certificate,
    DateTime validAfter,
  ) =>
      profile.profileType == 'IOS_APP_STORE' &&
      profile.profileState == 'ACTIVE' &&
      profile.bundleIdId == bundleId.id &&
      profile.certificateIds.contains(certificate.id) &&
      profile.expirationDate.isAfter(validAfter);

  static Future<AppleProvisioningProfileDto> _createOrRecoverProfile({
    required AppStoreConnectApi client,
    required String name,
    required AppleBundleIdentifierDto bundleId,
    required AppleSigningCertificateDto certificate,
    required DateTime validAfter,
  }) async {
    try {
      return await client.createAppStoreProfile(
        name: name,
        bundleIdId: bundleId.id,
        certificateId: certificate.id,
      );
    } on SmfError catch (creationError, creationStackTrace) {
      try {
        final recovered = _bestProfile(
          await client.listAppStoreProfiles(),
          bundleId,
          certificate,
          validAfter,
        );
        if (recovered != null) return recovered;
      } on Object {
        // Preserve the original mutation failure when reconciliation also fails.
      }
      Error.throwWithStackTrace(creationError, creationStackTrace);
    }
  }

  static String _availableProfileName(
    String bundleId,
    String serialNumber,
    Set<String> existingNames,
  ) {
    final serialSuffix = serialNumber.length <= 8 ? serialNumber : serialNumber.substring(serialNumber.length - 8);
    final base = 'SMF App Store $bundleId $serialSuffix';
    if (!existingNames.contains(base)) return base;
    var suffix = 2;
    while (existingNames.contains('$base $suffix')) {
      suffix++;
    }
    return '$base $suffix';
  }

  static void _validateProfile(
    AppleProvisioningProfileDto profile,
    AppleBundleIdentifierDto bundleId,
    AppleSigningCertificateDto certificate,
    DateTime validAfter,
  ) {
    SmfError.check(
      _profileMatches(profile, bundleId, certificate, validAfter),
      'Apple returned an invalid App Store profile for ${bundleId.identifier}.',
      SmfErrorCode.appleProfileInvalid,
    );
  }

  static String _normalizedBase64Profile(String value, String bundleId) {
    final normalized = value.replaceAll(RegExp(r'\s'), '');
    try {
      SmfError.check(
        base64Decode(normalized).isNotEmpty,
        'Apple returned an empty provisioning profile for $bundleId.',
        SmfErrorCode.appleProfileInvalid,
      );
    } on FormatException catch (error) {
      throw SmfError(
        'Apple returned malformed provisioning-profile content for $bundleId.',
        SmfErrorCode.appStoreConnectResponse,
        cause: error,
      );
    }
    return normalized;
  }

  static bool _isNonEmptyBase64(String value) {
    try {
      return base64Decode(value.replaceAll(RegExp(r'\s'), '')).isNotEmpty;
    } on FormatException {
      return false;
    }
  }

  static Future<List<int>> _certificateDer(
    AppleSigningCredentials credentials, {
    required ProcessRunner processRunner,
    Directory? temporaryRoot,
  }) async {
    final parent = temporaryRoot ?? Directory.systemTemp;
    final temporaryDirectory = await parent.createTemp('smf-certificate-');
    final p12Path = p.join(temporaryDirectory.path, 'distribution.p12');
    final pemPath = p.join(temporaryDirectory.path, 'distribution.pem');
    final derPath = p.join(temporaryDirectory.path, 'distribution.der');
    try {
      List<int> certificateBytes;
      try {
        certificateBytes = base64Decode(credentials.certificateBase64);
      } on FormatException catch (error) {
        throw SmfError(
          'The iOS distribution certificate is not valid Base64.',
          SmfErrorCode.invalidCertificate,
          cause: error,
        );
      }
      await File(p12Path).writeAsBytes(certificateBytes);
      await processRunner.run('/bin/chmod', <String>['600', p12Path]);
      try {
        await processRunner.run(
          'openssl',
          <String>[
            'pkcs12',
            '-in',
            p12Path,
            '-clcerts',
            '-nokeys',
            '-passin',
            'stdin',
            '-out',
            pemPath,
          ],
          options: RunOptions(input: '${credentials.certificatePassword}\n'),
        );
        await processRunner.run('openssl', <String>[
          'x509',
          '-in',
          pemPath,
          '-outform',
          'DER',
          '-out',
          derPath,
        ]);
      } on SmfError catch (error) {
        throw SmfError(
          'Could not read the Apple Distribution identity from the supplied '
          '.p12.',
          SmfErrorCode.invalidCertificate,
          cause: error,
        );
      }
      final der = await File(derPath).readAsBytes();
      SmfError.check(
        der.isNotEmpty,
        'The supplied .p12 did not contain an Apple Distribution certificate.',
        SmfErrorCode.invalidCertificate,
      );
      return der;
    } finally {
      try {
        await temporaryDirectory.delete(recursive: true);
      } on FileSystemException {
        // Best-effort cleanup must not hide the signing result.
      }
    }
  }

  static bool _bytesEqual(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    var difference = 0;
    for (var index = 0; index < first.length; index++) {
      difference |= first[index] ^ second[index];
    }
    return difference == 0;
  }
}
