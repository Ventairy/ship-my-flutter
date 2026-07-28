import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:smf_apple/src/apple/installed_profile.dart';
import 'package:smf_apple/src/apple/signing_session.dart';
import 'package:smf_apple/src/models/resolved_signing_assets.dart';
import 'package:smf_engine/smf_engine.dart' hide Platform;
import 'package:xml/xml.dart';

export 'installed_profile.dart';
export 'signing_session.dart';

/// Installs and validates temporary Apple signing assets.
final class AppleSigning {
  const AppleSigning._();

  static Future<Map<String, Object?>> _decodeProfile(
    String filePath,
    ProcessRunner processRunner,
  ) async {
    final decoded = await processRunner.run('security', <String>[
      'cms',
      '-D',
      '-i',
      filePath,
    ]);
    late final XmlDocument document;
    try {
      document = XmlDocument.parse(decoded.stdout);
    } on XmlException catch (error) {
      throw SmfError(
        'The provisioning profile did not decode to valid XML.',
        'INVALID_PROFILE',
        cause: error,
      );
    }
    final root = document.rootElement;
    final valueElement = root.name.local == 'plist' ? root.childElements.firstOrNull : root;
    Object? value;
    try {
      value = valueElement == null ? null : _parsePlist(valueElement);
    } on FormatException catch (error) {
      throw SmfError(
        'The provisioning profile contains an invalid plist value.',
        'INVALID_PROFILE',
        cause: error,
      );
    }
    if (value is! Map<String, Object?>) {
      throw const SmfError(
        'The provisioning profile did not decode to a plist dictionary.',
        'INVALID_PROFILE',
      );
    }
    return value;
  }

  static List<int> _decodeBase64(String value, String label, String code) {
    try {
      return base64Decode(value);
    } on FormatException catch (error) {
      throw SmfError('$label is not valid Base64.', code, cause: error);
    }
  }

  static Object? _parsePlist(XmlElement element) => switch (element.name.local) {
    'string' => element.innerText,
    'integer' => int.parse(element.innerText),
    'date' => DateTime.parse(element.innerText).toUtc(),
    'data' => base64Decode(element.innerText.replaceAll(RegExp(r'\s'), '')),
    'true' => true,
    'false' => false,
    'array' => <Object?>[
      for (final child in element.childElements) _parsePlist(child),
    ],
    'dict' => _parsePlistDict(element),
    _ => throw FormatException(
      'Unsupported plist element <${element.name.local}>.',
    ),
  };

  static Map<String, Object?> _parsePlistDict(XmlElement element) {
    final children = element.childElements.toList();
    final result = <String, Object?>{};
    for (var index = 0; index < children.length; index += 2) {
      SmfError.check(
        index + 1 < children.length && children[index].name.local == 'key' && children[index + 1].name.local != 'key',
        'The provisioning profile plist contains an invalid dictionary.',
        'INVALID_PROFILE',
      );
      final key = children[index].innerText;
      SmfError.check(
        key.isNotEmpty && !result.containsKey(key),
        'The provisioning profile plist contains a missing or duplicate key.',
        'INVALID_PROFILE',
      );
      result[key] = _parsePlist(children[index + 1]);
    }
    return result;
  }

  static Future<void> _removeIfExists(String filePath) async {
    try {
      final type = await FileSystemEntity.type(filePath, followLinks: false);
      if (type == FileSystemEntityType.file || type == FileSystemEntityType.link) {
        await File(filePath).delete();
      }
    } on FileSystemException {
      // Cleanup is best effort and never hides the delivery result.
    }
  }

  /// Installs signing assets for one bundle and its extensions.
  static Future<AppleSigningSession> install(
    AppleResolvedSigningAssets assets,
    String bundleId, {
    ProcessRunner processRunner = const SystemProcessRunner(),
    bool? isMacOS,
    String? homeDirectory,
    Directory? temporaryRoot,
  }) async {
    if (!(isMacOS ?? Platform.isMacOS)) {
      throw const SmfError(
        'iOS signing requires a macOS runner.',
        'MACOS_REQUIRED',
      );
    }
    final parent = temporaryRoot ?? Directory.systemTemp;
    final credentials = assets.credentials;
    final temporaryDirectory = await parent.createTemp('smf-signing-');
    final keychainPath = p.join(temporaryDirectory.path, 'signing.keychain-db');
    final keychainPassword = _randomToken(32);
    final certificatePath = p.join(temporaryDirectory.path, 'distribution.p12');
    final profilesDirectory = p.join(
      homeDirectory ?? Platform.environment['HOME'] ?? Directory.current.path,
      'Library',
      'MobileDevice',
      'Provisioning Profiles',
    );
    final installedPaths = <String>[];
    List<String>? previousKeychains;
    var keychainCreated = false;
    var installationCompleted = false;

    Future<void> cleanup() async {
      for (final installedPath in installedPaths) {
        await _removeIfExists(installedPath);
      }
      final keychainsToRestore = previousKeychains;
      if (keychainsToRestore != null) {
        await processRunner.run('security', <String>[
          'list-keychains',
          '-d',
          'user',
          '-s',
          ...keychainsToRestore,
        ], options: const RunOptions(allowFailure: true));
      }
      if (keychainCreated) {
        await processRunner.run('security', <String>[
          'delete-keychain',
          keychainPath,
        ], options: const RunOptions(allowFailure: true));
      }
      try {
        await temporaryDirectory.delete(recursive: true);
      } on FileSystemException {
        // Best effort.
      }
    }

    try {
      await File(certificatePath).writeAsBytes(
        _decodeBase64(
          credentials.certificateBase64,
          'The iOS distribution certificate',
          'INVALID_CERTIFICATE',
        ),
      );
      await processRunner.run('/bin/chmod', <String>['600', certificatePath]);
      keychainCreated = true;
      await processRunner.run('security', <String>[
        'create-keychain',
        '-p',
        keychainPassword,
        keychainPath,
      ]);
      await processRunner.run('security', <String>[
        'set-keychain-settings',
        '-lut',
        '21600',
        keychainPath,
      ]);
      await processRunner.run('security', <String>[
        'unlock-keychain',
        '-p',
        keychainPassword,
        keychainPath,
      ]);
      await processRunner.run('security', <String>[
        'import',
        certificatePath,
        '-P',
        credentials.certificatePassword,
        '-A',
        '-t',
        'cert',
        '-f',
        'pkcs12',
        '-k',
        keychainPath,
      ]);
      await processRunner.run('security', <String>[
        'set-key-partition-list',
        '-S',
        'apple-tool:,apple:,codesign:',
        '-s',
        '-k',
        keychainPassword,
        keychainPath,
      ]);
      final existingKeychains = await processRunner.run(
        'security',
        const <String>['list-keychains', '-d', 'user'],
      );
      previousKeychains = existingKeychains.stdout
          .split('\n')
          .map((line) => line.trim().replaceAll(RegExp(r'^"|"$'), ''))
          .where((line) => line.isNotEmpty)
          .toList();
      await processRunner.run('security', <String>[
        'list-keychains',
        '-d',
        'user',
        '-s',
        keychainPath,
        ...previousKeychains,
      ]);

      final profileInput = assets.profilesByBundleId;
      SmfError.check(
        profileInput.containsKey(bundleId),
        'Apple signing data is missing the main bundle ID $bundleId.',
        'SIGNING_TARGET_MISSING',
      );
      await Directory(profilesDirectory).create(recursive: true);
      final profiles = <AppleInstalledProfile>[];
      for (final entry in profileInput.entries) {
        final sourcePath = p.join(
          temporaryDirectory.path,
          '${_randomToken(16)}.mobileprovision',
        );
        await File(sourcePath).writeAsBytes(
          _decodeBase64(
            entry.value,
            'Provisioning profile for ${entry.key}',
            'INVALID_PROFILE',
          ),
        );
        await processRunner.run('/bin/chmod', <String>['600', sourcePath]);
        final profile = await _decodeProfile(sourcePath, processRunner);
        final entitlements = profile['Entitlements'];
        final teamIdentifiers = profile['TeamIdentifier'];
        if (entitlements is! Map<String, Object?> || teamIdentifiers is! List<Object?> || teamIdentifiers.length != 1) {
          throw const SmfError(
            'Provisioning profile signing identity is incomplete.',
            'INVALID_PROFILE',
          );
        }
        final applicationIdentifier = entitlements['application-identifier'];
        final teamId = teamIdentifiers.first;
        if (applicationIdentifier is! String ||
            teamId is! String ||
            teamId.isEmpty ||
            !applicationIdentifier.startsWith('$teamId.')) {
          throw const SmfError(
            'Provisioning profile signing identity is invalid.',
            'INVALID_PROFILE',
          );
        }
        final actualBundleId = applicationIdentifier.substring(teamId.length + 1);
        final profileName = profile['Name'];
        final uuid = profile['UUID'];
        final expirationDate = profile['ExpirationDate'];
        if (profileName is! String || profileName.isEmpty || uuid is! String || expirationDate is! DateTime) {
          throw const SmfError(
            'Provisioning profile name, UUID, or expiration is missing.',
            'INVALID_PROFILE',
          );
        }
        SmfError.check(
          RegExp(
            r'^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$',
          ).hasMatch(uuid),
          'Provisioning profile "$profileName" has an invalid UUID.',
          'INVALID_PROFILE',
        );
        SmfError.check(
          expirationDate.isAfter(DateTime.now().toUtc()),
          'Provisioning profile "$profileName" has expired.',
          'INVALID_PROFILE',
        );
        SmfError.check(
          actualBundleId == entry.key,
          'Provisioning profile "$profileName" is for $actualBundleId, not '
              '${entry.key}.',
          'PROFILE_BUNDLE_ID_MISMATCH',
        );
        final installedPath = p.join(profilesDirectory, '$uuid.mobileprovision');
        if (await SmfFileSystem.exists(installedPath)) {
          SmfError.check(
            _bytesEqual(
              await File(installedPath).readAsBytes(),
              await File(sourcePath).readAsBytes(),
            ),
            'A different provisioning profile already exists at $installedPath.',
            'PROFILE_COLLISION',
          );
        } else {
          await File(sourcePath).copy(installedPath);
          await processRunner.run('/bin/chmod', <String>[
            '600',
            installedPath,
          ]);
          installedPaths.add(installedPath);
        }
        profiles.add(
          AppleInstalledProfile(
            bundleId: entry.key,
            uuid: uuid,
            name: profileName,
            teamId: teamId,
            installedPath: installedPath,
          ),
        );
      }
      SmfError.check(profiles.isNotEmpty, 'No provisioning profiles supplied.');
      SmfError.check(
        profiles.map((profile) => profile.teamId).toSet().length == 1,
        'All provisioning profiles must belong to the same Apple team.',
        'PROFILE_TEAM_MISMATCH',
      );

      final exportOptionsPath = p.join(
        temporaryDirectory.path,
        'ExportOptions.plist',
      );
      await File(exportOptionsPath).writeAsString(_exportOptionsPlist(profiles));
      final session = AppleSigningSession(
        keychainPath: keychainPath,
        keychainPassword: keychainPassword,
        profiles: List<AppleInstalledProfile>.unmodifiable(profiles),
        exportOptionsPath: exportOptionsPath,
        cleanup: cleanup,
      );
      installationCompleted = true;
      return session;
    } finally {
      if (!installationCompleted) {
        await cleanup();
      }
    }
  }

  static String _exportOptionsPlist(List<AppleInstalledProfile> profiles) {
    final builder = XmlBuilder();
    builder
      ..processing('xml', 'version="1.0" encoding="UTF-8"')
      ..doctype(
        'plist',
        publicId: '-//Apple//DTD PLIST 1.0//EN',
        systemId: 'http://www.apple.com/DTDs/PropertyList-1.0.dtd',
      )
      ..element(
        'plist',
        attributes: <String, String>{'version': '1.0'},
        nest: () {
          builder.element(
            'dict',
            nest: () {
              _plistString(builder, 'method', 'app-store-connect');
              _plistString(builder, 'destination', 'export');
              _plistString(builder, 'signingStyle', 'manual');
              _plistString(builder, 'signingCertificate', 'Apple Distribution');
              _plistString(builder, 'teamID', profiles.first.teamId);
              builder
                ..element('key', nest: 'provisioningProfiles')
                ..element(
                  'dict',
                  nest: () {
                    for (final profile in profiles) {
                      _plistString(builder, profile.bundleId, profile.name);
                    }
                  },
                )
                ..element('key', nest: 'uploadSymbols')
                ..element('true')
                ..element('key', nest: 'compileBitcode')
                ..element('false');
            },
          );
        },
      );
    return '${builder.buildDocument().toXmlString(pretty: true)}\n';
  }

  static void _plistString(XmlBuilder builder, String key, String value) {
    builder
      ..element('key', nest: key)
      ..element('string', nest: value);
  }

  static String _randomToken(int bytes) {
    final random = Random.secure();
    return List<int>.generate(
      bytes,
      (_) => random.nextInt(256),
    ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
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
