part of dax;


/**
 * Basic color shader, no fancy effects.
 * The default color is pure white, with full opacity.
 *
 * I wonder if this is the same as Ambient Color ?
 */
class ColorLayer extends MaterialLayer {

  String get glslFragment => """
uniform vec3 uColor;
uniform float uAlpha;

void main(void) {
    gl_FragColor = vec4(uColor, uAlpha);
}
  """;

  Map<String, dynamic> onSetup(World world, Model model, Renderer renderer) {
    return {
      'uColor': new Vector3(1.0, 1.0, 1.0),
      'uAlpha': 1.0,
    };
  }

}