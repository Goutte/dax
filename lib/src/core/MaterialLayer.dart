part of dax;

/**
 * A Material is made of one or more MaterialLayer, which basically are shaders.
 * The Material preprocessor will merge all the layers into two generated shaders.
 *
 * This is a class to extend, and override :
 * - glslFragment
 * - glslVertex
 * - onSetup()
 * - onDraw()
 *
 * WARNING: there still are limitations on the GLSL shaders you can provide.
 */
abstract class MaterialLayer {

  /// GLSL source code for the fragment shader, to override.
  String get glslFragment => "";
  /// GLSL source code for the vertex shader, to override.
  String get glslVertex => "";

  Shader fragment;
  Shader vertex;

  Map<String, dynamic> values = {};

  String get uid  => this.runtimeType.toString();
  String get name => this.runtimeType.toString();

  /// CONSTRUCTOR --------------------------------------------------------------

  MaterialLayer() {
    fragment = new Shader(glslFragment);
    vertex = new Shader(glslVertex);
  }

  /// API ----------------------------------------------------------------------

  /// This is called once by the renderer, on material setup.
  /// The returned Map should map variable names to values.
  /// Override this to provide the values of the uniforms and attributes of the shaders.
  Map<String, dynamic> onSetup(World world, Model model, Renderer renderer) => {};

  /// This is called by the renderer, on each drawing of the material.
  /// The returned Map should map variable names to values.
  /// Override this to provide the values of the uniforms and attributes of the shaders.
  Map<String, dynamic> onDraw(World world, Model model, Renderer renderer) => {};
}

