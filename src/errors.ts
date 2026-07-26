export class ShipError extends Error {
  constructor(
    message: string,
    readonly code: string,
    options?: ErrorOptions,
  ) {
    super(message, options);
    this.name = "ShipError";
  }
}

export function invariant(
  condition: unknown,
  message: string,
  code = "INVALID_STATE",
): asserts condition {
  if (!condition) {
    throw new ShipError(message, code);
  }
}
