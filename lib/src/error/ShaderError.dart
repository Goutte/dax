part of dax;


/**
 * Thrown when there's a problem with Shaders.
 */
class ShaderError implements Exception {
  /**
   * A message describing the shader error.
   */
  final String message;

  /**
   * Creates a new ShaderError with an optional error [message].
   */
  const ShaderError([this.message = ""]);

  String toString() => "ShaderError: $message";
}
