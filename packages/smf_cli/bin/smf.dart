import 'dart:io';

import 'package:smf_cli/src/executables.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runSmfExecutable(arguments);
}
