import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  final write = arguments.length == 1 && arguments.single == '--write';
  if (arguments.isNotEmpty && !write) {
    stderr.writeln('Usage: dart run tool/check_dart_format.dart [--write]');
    exitCode = 64;
    return;
  }
  final repositoryRoot = Directory.current.path;
  final files = <String>[];
  for (final root in <String>['packages', 'tool']) {
    await for (final entity in Directory(
      p.join(repositoryRoot, root),
    ).list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (p.split(entity.path).contains('.dart_tool')) continue;
      if (entity.path.endsWith('.g.dart') || entity.path.endsWith('.freezed.dart')) {
        continue;
      }
      files.add(p.relative(entity.path, from: repositoryRoot));
    }
  }
  files.sort();

  final process = await Process.start(
    Platform.resolvedExecutable,
    <String>[
      'format',
      if (!write) ...<String>[
        '--output=none',
        '--set-exit-if-changed',
      ],
      ...files,
    ],
    workingDirectory: repositoryRoot,
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}
