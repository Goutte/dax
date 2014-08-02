part of dax;


/**
 * Basic color shader, no fancy effects.
 * Alpha will not work unless you enable GL_BLEND. And even then, it will be
 * highly dependent on the scene graph drawing order, which is always the same
 * right now. (and not guaranteed either, feel free to fix this)
 * The default [color] is poupou (#FF3399), with full opacity.
 */
class ColorLayer extends MaterialLayer {

  Vector3 color = new Vector3(1.0, 0.2, 0.6);
  double  alpha = 1.0;

  ColorLayer([Vector3 color, double alpha]) : super() {
    if (color != null) {
      this.color.setFrom(color);
    }
    if (alpha != null) {
      this.alpha = alpha;
    }
  }

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
        'uAlpha': alpha,
    };
  }
}