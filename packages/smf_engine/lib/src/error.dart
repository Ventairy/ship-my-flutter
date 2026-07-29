import 'package:smf_engine/src/enums/smf_error_code.dart';

export 'package:smf_engine/src/enums/smf_error_code.dart';

/// An actionable SMF domain failure with a stable automation code.
final class SmfError implements Exception {
  /// Creates an SMF failure with a stable machine-readable [code].
  const SmfError(this.message, this.code, {this.cause});

  /// Human-readable failure details.
  final String message;

  /// Stable failure category used by automation.
  final SmfErrorCode code;

  /// Optional lower-level error that caused this failure.
  final Object? cause;

  /// Throws an [SmfError] when [isConditionSatisfied] is false.
  static void check(
    // This intentionally mirrors Dart's assert(condition, message) convention.
    // ignore: avoid_positional_boolean_parameters
    bool isConditionSatisfied,
    String message, [
    SmfErrorCode code = SmfErrorCode.invalidState,
  ]) {
    if (!isConditionSatisfied) throw SmfError(message, code);
  }

  @override
  String toString() => 'SmfError(${code.value}): $message';
}
