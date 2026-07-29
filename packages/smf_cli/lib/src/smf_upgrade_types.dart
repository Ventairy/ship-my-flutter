part of 'upgrade.dart';

typedef LatestSmfVersionLoader = Future<String?> Function();
typedef SmfInstaller =
    Future<dart_io.ProcessResult> Function(
      String executable,
      List<String> arguments,
    );
