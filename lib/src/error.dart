final class ShipError implements Exception {
  const ShipError(this.message, this.code, {this.cause});

  final String message;
  final String code;
  final Object? cause;

  @override
  String toString() => 'ShipError($code): $message';
}

Never _invalid(String message, [String code = 'INVALID_STATE']) {
  throw ShipError(message, code);
}

void invariant(
  bool condition,
  String message, [
  String code = 'INVALID_STATE',
]) {
  if (!condition) {
    _invalid(message, code);
  }
}
