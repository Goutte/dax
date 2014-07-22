part of dax;


/**
 * Basic color shader, no fancy effects.
 * The default color is pure white, with full opacity.
 *
 * I wonder if this is the same as Ambient Color ?
 */
class DidiLayer extends MaterialLayer {

  String get glslFragment => """
uniform vec3 uColor;
uniform float uAlpha;

void main(void) {
    gl_FragColor = vec4(uColor, uAlpha);
}
  """;

  Map<String, dynamic> onSetup(World world, Model model, Renderer renderer) {
    return {
      'uAlpha': 1.0,
    };
  }

  double _t = 0.0;

  Map<String, dynamic> onDraw(World world, Model model, Renderer renderer) {
    _t += 0.02;
    double _red = (sin(_t) + 1) / 2;
    return {
      'uColor': new Vector3(_red, 1.0-_red, 0.5),
    };
  }

}