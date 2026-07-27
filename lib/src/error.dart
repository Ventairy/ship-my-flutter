final class SmfError implements Exception {
  const SmfError(this.message, this.code, {this.cause});

  final String message;
  final String code;
  final Object? cause;

  @override
  String toString() => 'SmfError($code): $message';
}

Never _invalid(String message, [String code = 'INVALID_STATE']) {
  throw SmfError(message, code);
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
