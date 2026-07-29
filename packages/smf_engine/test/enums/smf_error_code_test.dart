import 'package:smf_engine/smf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('error codes have unique stable machine-readable values', () {
    final values = <String>[
      for (final code in SmfErrorCode.values) code.value,
    ];

    expect(values.toSet(), hasLength(values.length));
    expect(
      values,
      everyElement(matches(RegExp(r'^[A-Z][A-Z0-9_]*$'))),
    );
  });
}
