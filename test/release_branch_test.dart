import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

void main() {
  test('uses the internal platform release branch convention', () {
    expect(releaseBranchName(Platform.ios), 'ship-my-flutter/ios');
  });
}
