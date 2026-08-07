import 'package:smf_hooks/smf_hooks.dart';

final class FailingBeforeBuildHook extends SmfHook {
  @override
  Future<void> run(SmfBeforeBuildContext context) async {
    await context.runCommand(
      'pwd > pwd.txt; exit 7',
      shouldRunFromRepositoryRoot: true,
    );
  }
}

Future<void> main() => runSmfHook(FailingBeforeBuildHook());
