import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('uses the internal platform release branch convention', () {
    expect(releaseBranchName(Platform.ios), 'smf/ios');
  });
}
