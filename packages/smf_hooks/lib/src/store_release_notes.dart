part of 'smf_hooks_sdk.dart';

/// Writes localized store notes for one planned platform release.
final class StoreReleaseNotes {
  const StoreReleaseNotes._({
    required File file,
    required HookReleasePlatform platform,
    required String version,
  }) : _file = file,
       _platform = platform,
       _version = version;

  final File _file;
  final HookReleasePlatform _platform;
  final String _version;

  /// Maximum number of characters accepted by this platform's store.
  int get characterLimit => _platform.characterLimit;

  /// Writes one localized [message] for this platform release.
  ///
  /// Existing platforms, versions, and locales are preserved.
  void write({
    required String locale,
    required String message,
  }) {
    final normalizedLocale = locale.trim();
    if (normalizedLocale.isEmpty) {
      throw const FormatException('Store release note locale cannot be empty.');
    }
    if (message.trim().isEmpty) {
      throw const FormatException(
        'Store release note message cannot be empty.',
      );
    }
    if (message.length > characterLimit) {
      throw FormatException(
        '${_platform.name} store release note for $normalizedLocale must be at most '
        '$characterLimit characters.',
      );
    }
    final root = _file.existsSync()
        ? _HookModelDecoder.object(
            jsonDecode(_file.readAsStringSync()),
            'store release notes',
          )
        : <String, Object?>{};
    final platformNotes = _HookModelDecoder.optionalObject(
      root[_platform.name],
      _platform.name,
    );
    final versionNotes = _HookModelDecoder.optionalObject(
      platformNotes[_version],
      '${_platform.name}.$_version',
    );
    versionNotes[normalizedLocale] = message;
    platformNotes[_version] = versionNotes;
    root[_platform.name] = platformNotes;

    _writeAtomically(
      '${const JsonEncoder.withIndent('  ').convert(root)}\n',
    );
  }

  void _writeAtomically(String contents) {
    _file.parent.createSync(recursive: true);
    final targetType = FileSystemEntity.typeSync(
      _file.path,
      followLinks: false,
    );
    final targetMode = targetType == FileSystemEntityType.file ? _file.statSync().mode & 0x1ff : null;
    final temporary = File(
      '${_file.path}.smf-write-$pid-'
      '${Random.secure().nextInt(1 << 32)}.tmp',
    );
    try {
      temporary.writeAsStringSync(
        contents,
        mode: FileMode.writeOnly,
        flush: true,
      );
      if (targetMode != null && !Platform.isWindows) {
        final result = Process.runSync('/bin/chmod', <String>[
          targetMode.toRadixString(8).padLeft(3, '0'),
          temporary.path,
        ]);
        if (result.exitCode != 0) {
          throw FileSystemException(
            'Could not preserve store release note permissions',
            _file.path,
          );
        }
      }
      temporary.renameSync(_file.path);
    } finally {
      if (temporary.existsSync()) {
        temporary.deleteSync();
      }
    }
  }
}
