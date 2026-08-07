import 'package:smf_engine/apple.dart';
import 'package:test/test.dart';

void main() {
  test('when a build omits expiration, it should decode as not expired', () {
    final attributes = BuildAttributesDto.fromJson(<String, Object?>{
      'version': '7',
      'processingState': 'VALID',
    });

    expect(attributes.isExpired, isFalse);
  });
}
