import 'package:ship_my_flutter/ship_my_flutter.dart';
import 'package:test/test.dart';

void main() {
  test('when encoding a no-op command, it should omit every absent output', () {
    expect(const CommandResult(phase: 'noop').toJson(), <String, Object?>{
      'phase': 'noop',
    });
  });
}
