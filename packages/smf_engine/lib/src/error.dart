final class SmfError implements Exception {
  /// Creates an SMF failure with a stable machine-readable [code].
  const SmfError(this.message, this.code, {this.cause});

  /// Human-readable failure details.
  final String message;

  /// Stable failure category used by automation.
  final String code;

  /// Optional lower-level error that caused this failure.
  final Object? cause;

  /// Throws an [SmfError] when [condition] is false.
  static void check(
    // This intentionally mirrors Dart's assert(condition, message) convention.
    // ignore: avoid_positional_boolean_parameters
    bool condition,
    String message, [
    String code = 'INVALID_STATE',
  ]) {
    if (!condition) throw SmfError(message, code);
  }

  @override
  String toString() => 'SmfError($code): $message';
}
