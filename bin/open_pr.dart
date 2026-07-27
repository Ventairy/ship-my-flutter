import 'dart:io';

import 'package:smf/smf.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runSmfCli(<String>['open-pr', ...arguments]);
}
