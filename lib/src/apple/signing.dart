import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import '../error.dart';
import '../model.dart' hide Platform;
import '../process_runner.dart';
import '../serialization.dart';

final class InstalledProfile {
  const InstalledProfile({
    required this.bundleId,
    required this.uuid,
    required this.name,
    required this.teamId,
    required this.installedPath,
  });

  final String bundleId;
  final String uuid;
  final String name;
  final String teamId;
  final String installedPath;
}

final class SigningSession {
  const SigningSession({
    required this.keychainPath,
    required this.keychainPassword,
    required this.profiles,
    required this.exportOptionsPath,
    required Future<void> Function() cleanup,
  }) : _cleanup = cleanup;

  final String keychainPath;
  final String keychainPassword;
  final List<InstalledProfile> profiles;
  final String exportOptionsPath;
  final Future<void> Function() _cleanup;

  Future<void> cleanup() => _cleanup();
}

Map<String, String> _parseProfileInput(String value, String bundleId) {
  final trimmed = value.trim();
  if (!trimmed.startsWith('{')) return <String, String>{bundleId: trimmed};
  Object? decoded;
  try {
    decoded = jsonDecode(trimmed);
  } on FormatException catch (error) {
    throw ShipError(
      'Provisioning profiles JSON is malformed.',
      'INVALID_PROFILE',
      cause: error,
    );
  }
  if (decoded is! Map<Object?, Object?>) {
    throw const ShipError(
      'Provisioning profiles JSON must be an object.',
      'INVALID_PROFILE',
    );
  }
  final result = <String, String>{};
  for (final entry in decoded.entries) {
    final key = entry.key;
    final encodedProfile = entry.value;
    if (key is! String || encodedProfile is! String || encodedProfile.isEmpty) {
      throw const ShipError(
        'Every provisioning profile must be a Base64 string.',
        'INVALID_PROFILE',
      );
    }
    result[key] = encodedProfile;
  }
  return result;
}

Future<Map<String, Object?>> _decodeProfile(
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
    throw ShipError(
      'The provisioning profile did not decode to valid XML.',
      'INVALID_PROFILE',
      cause: error,
    );
  }
  final root = document.rootElement;
  final valueElement = root.name.local == 'plist'
      ? root.childElements.firstOrNull
      : root;
  final value = valueElement == null ? null : _parsePlist(valueElement);
  if (value is! Map<String, Object?>) {
    throw const ShipError(
      'The provisioning profile did not decode to a plist dictionary.',
      'INVALID_PROFILE',
    );
  }
  return value;
}

List<int> _decodeBase64(String value, String label, String code) {
  try {
    return base64Decode(value);
  } on FormatException catch (error) {
    throw ShipError('$label is not valid Base64.', code, cause: error);
  }
}

Object? _parsePlist(XmlElement element) => switch (element.name.local) {
  'string' => element.innerText,
  'integer' => int.parse(element.innerText),
  'true' => true,
  'false' => false,
  'array' => <Object?>[
    for (final child in element.childElements) _parsePlist(child),
  ],
  'dict' => _parsePlistDict(element),
  _ => element.innerText,
};

Map<String, Object?> _parsePlistDict(XmlElement element) {
  final children = element.childElements.toList();
  final result = <String, Object?>{};
  for (var index = 0; index < children.length; index += 2) {
    invariant(
      index + 1 < children.length && children[index].name.local == 'key',
      'The provisioning profile plist contains an invalid dictionary.',
      'INVALID_PROFILE',
    );
    result[children[index].innerText] = _parsePlist(children[index + 1]);
  }
  return result;
}

Future<void> _removeIfExists(String filePath) async {
  try {
    final type = await FileSystemEntity.type(filePath, followLinks: false);
    if (type == FileSystemEntityType.file ||
        type == FileSystemEntityType.link) {
      await File(filePath).delete();
    }
  } on FileSystemException {
    // Cleanup is best effort and never hides the delivery result.
  }
}

Future<SigningSession> installSigningAssets(
  SigningCredentials credentials,
  String bundleId, {
  ProcessRunner processRunner = const SystemProcessRunner(),
  bool? isMacOS,
  String? homeDirectory,
  Directory? temporaryRoot,
}) async {
  if (!(isMacOS ?? Platform.isMacOS)) {
    throw const ShipError(
      'iOS signing requires a macOS runner.',
      'MACOS_REQUIRED',
    );
  }
  final parent = temporaryRoot ?? Directory.systemTemp;
  final temporaryDirectory = await parent.createTemp(
    'ship-my-flutter-signing-',
  );
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
        .map((String line) => line.trim().replaceAll(RegExp(r'^"|"$'), ''))
        .where((String line) => line.isNotEmpty)
        .toList();
    await processRunner.run('security', <String>[
      'list-keychains',
      '-d',
      'user',
      '-s',
      keychainPath,
      ...previousKeychains,
    ]);

    final profileInput = _parseProfileInput(
      credentials.provisioningProfiles,
      bundleId,
    );
    await Directory(profilesDirectory).create(recursive: true);
    final profiles = <InstalledProfile>[];
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
      if (entitlements is! Map<String, Object?> ||
          teamIdentifiers is! List<Object?> ||
          teamIdentifiers.isEmpty) {
        throw const ShipError(
          'Provisioning profile signing identity is incomplete.',
          'INVALID_PROFILE',
        );
      }
      final applicationIdentifier = entitlements['application-identifier'];
      final teamId = teamIdentifiers.first;
      if (applicationIdentifier is! String || teamId is! String) {
        throw const ShipError(
          'Provisioning profile signing identity is invalid.',
          'INVALID_PROFILE',
        );
      }
      final actualBundleId = applicationIdentifier.replaceFirst('$teamId.', '');
      final profileName = profile['Name'];
      final uuid = profile['UUID'];
      if (profileName is! String || uuid is! String) {
        throw const ShipError(
          'Provisioning profile name or UUID is missing.',
          'INVALID_PROFILE',
        );
      }
      invariant(
        RegExp(r'^[A-Za-z0-9-]+$').hasMatch(uuid),
        'Provisioning profile "$profileName" has an invalid UUID.',
        'INVALID_PROFILE',
      );
      invariant(
        actualBundleId == entry.key,
        'Provisioning profile "$profileName" is for $actualBundleId, not '
            '${entry.key}.',
        'PROFILE_BUNDLE_ID_MISMATCH',
      );
      final installedPath = p.join(profilesDirectory, '$uuid.mobileprovision');
      if (await fileExists(installedPath)) {
        invariant(
          _bytesEqual(
            await File(installedPath).readAsBytes(),
            await File(sourcePath).readAsBytes(),
          ),
          'A different provisioning profile already exists at $installedPath.',
          'PROFILE_COLLISION',
        );
      } else {
        await File(sourcePath).copy(installedPath);
        installedPaths.add(installedPath);
      }
      profiles.add(
        InstalledProfile(
          bundleId: entry.key,
          uuid: uuid,
          name: profileName,
          teamId: teamId,
          installedPath: installedPath,
        ),
      );
    }
    invariant(profiles.isNotEmpty, 'No provisioning profiles supplied.');
    invariant(
      profiles
              .map((InstalledProfile profile) => profile.teamId)
              .toSet()
              .length ==
          1,
      'All provisioning profiles must belong to the same Apple team.',
      'PROFILE_TEAM_MISMATCH',
    );

    final exportOptionsPath = p.join(
      temporaryDirectory.path,
      'ExportOptions.plist',
    );
    await File(exportOptionsPath).writeAsString(_exportOptionsPlist(profiles));
    final session = SigningSession(
      keychainPath: keychainPath,
      keychainPassword: keychainPassword,
      profiles: List<InstalledProfile>.unmodifiable(profiles),
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

String _exportOptionsPlist(List<InstalledProfile> profiles) {
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

void _plistString(XmlBuilder builder, String key, String value) {
  builder
    ..element('key', nest: key)
    ..element('string', nest: value);
}

String _randomToken(int bytes) {
  final random = Random.secure();
  return List<int>.generate(
    bytes,
    (_) => random.nextInt(256),
  ).map((int value) => value.toRadixString(16).padLeft(2, '0')).join();
}

bool _bytesEqual(List<int> first, List<int> second) {
  if (first.length != second.length) return false;
  var difference = 0;
  for (var index = 0; index < first.length; index++) {
    difference |= first[index] ^ second[index];
  }
  return difference == 0;
}
