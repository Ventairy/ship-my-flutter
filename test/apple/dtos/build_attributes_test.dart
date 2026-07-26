import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

void main() {
  test('when a build omits expiration, it should decode as not expired', () {
    final attributes = BuildAttributes.fromJson(<String, Object?>{
      'version': '7',
      'processingState': 'VALID',
    });

    expect(attributes.expired, isFalse);
  });
}
