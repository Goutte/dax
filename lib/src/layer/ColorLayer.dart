part of dax;


/**
 * Basic color shader, no fancy effects.
 * The default [color] is poupou (#FF3399), with full opacity.
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
      'uColor': color,
      'uAlpha': 1.0,
    };
  }

  Vector3 color = new Vector3(1.0, 0.2, 0.6); // poupou = #FF3399

  ColorLayer([Vector3 color]) : super() {
    if (color != null) {
      this.color.setFrom(color);
    }
  }
}