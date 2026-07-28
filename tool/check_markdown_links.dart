import 'dart:io';

import 'package:path/path.dart' as p;

final _markdownLink = RegExp(r'\[[^\]]*\]\(([^)]+)\)');
final _absoluteUri = RegExp('^[a-zA-Z][a-zA-Z0-9+.-]*:');
final _canonicalRepositoryLink = RegExp(
  r'^https://github\.com/Ventairy/smf/(?:blob|tree)/main/([^#?]+)',
);

Future<void> main() async {
  final root = p.normalize(p.absolute(Directory.current.path));
  final failures = <String>[];
  final files = await _markdownFiles(root);

  for (final file in files) {
    final source = await file.readAsString();
    for (final match in _markdownLink.allMatches(source)) {
      final rawTarget = match.group(1);
      if (rawTarget == null) continue;
      final target = _linkTarget(rawTarget, root);
      if (target == null) continue;

      final resolved = p.normalize(
        p.isAbsolute(target) ? Uri.decodeComponent(target) : p.join(p.dirname(file.path), Uri.decodeComponent(target)),
      );
      if (!p.isWithin(root, resolved) && resolved != root) {
        failures.add(
          '${p.relative(file.path, from: root)} links outside the repository: '
          '$rawTarget',
        );
        continue;
      }
      if (!await FileSystemEntity.isFile(resolved) && !await FileSystemEntity.isDirectory(resolved)) {
        failures.add(
          '${p.relative(file.path, from: root)} has a missing link: $rawTarget',
        );
      }
    }
  }

  if (failures.isEmpty) {
    stdout.writeln('Checked ${files.length} Markdown files.');
    return;
  }
  failures.forEach(stderr.writeln);
  exitCode = 1;
}

Future<List<File>> _markdownFiles(String root) async {
  final files = <File>[];
  await for (final entity in Directory(root).list(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File || p.extension(entity.path) != '.md') continue;
    final relative = p.relative(entity.path, from: root);
    final segments = p.split(relative);
    if (segments.any(
      (segment) => segment == '.dart_tool' || segment == '.git' || segment == 'build',
    )) {
      continue;
    }
    files.add(entity);
  }
  files.sort((first, second) => first.path.compareTo(second.path));
  return files;
}

String? _linkTarget(String rawTarget, String root) {
  var target = rawTarget.trim();
  final titleSeparator = target.indexOf(RegExp(r'''\s+["']'''));
  if (titleSeparator >= 0) target = target.substring(0, titleSeparator);
  if (target.startsWith('<') && target.endsWith('>')) {
    target = target.substring(1, target.length - 1);
  }
  if (target.isEmpty || target.startsWith('#')) return null;

  final canonical = _canonicalRepositoryLink.firstMatch(target);
  if (canonical != null) return p.join(root, canonical.group(1));
  if (_absoluteUri.hasMatch(target)) return null;

  return target.split('#').first.split('?').first;
}
