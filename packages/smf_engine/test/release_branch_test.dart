import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('uses one shared release branch for every platform', () {
    expect(releaseBranchName, 'smf/release');
  });
}
