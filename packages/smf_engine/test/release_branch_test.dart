import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('uses one app-scoped release branch for every platform', () {
    expect(ReleaseReference.branch('customer'), 'smf/customer/release');
  });
}
