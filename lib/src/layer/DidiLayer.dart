part of dax;


/**
 * Didi's joy
 * This is a blackboard for testing/explaining a rainbow shader to a friend.
 */
class DidiLayer extends MaterialLayer {

  String get glslVertex => """
uniform float uMinY;
uniform float uMaxY;
varying float rainbowPos;

void main(void) {
  if (uMaxY == uMinY) {
    rainbowPos = 0.0;
  } else {
    rainbowPos = ( VERTEX_POSITION[1] - uMinY ) / ( uMaxY - uMinY );
  }
}
  """;
  String get glslFragment => """
uniform vec3 uColor;
uniform float uAlpha;

varying float rainbowPos;

vec3 rainbow(float x)
{
	/*
		Target colors
		=============

		L  x   color
		0  0.0 vec4(1.0, 0.0, 0.0, 1.0);
		1  0.2 vec4(1.0, 0.5, 0.0, 1.0);
		2  0.4 vec4(1.0, 1.0, 0.0, 1.0);
		3  0.6 vec4(0.0, 0.5, 0.0, 1.0);
		4  0.8 vec4(0.0, 0.0, 1.0, 1.0);
		5  1.0 vec4(0.5, 0.0, 0.5, 1.0);
	*/

	float level = floor(x * 6.0);
	float r = float(level <= 2.0) + float(level > 4.0) * 0.5;
	float g = max(1.0 - abs(level - 2.0) * 0.5, 0.0);
	float b = (1.0 - (level - 4.0) * 0.5) * float(level >= 4.0);
	return vec3(r, g, b);
}

void main(void) {
    gl_FragColor = vec4(rainbow(rainbowPos), uAlpha);
}
  """;

  Map<String, dynamic> onSetup(World world, Model model, Renderer renderer) {
    return {
      'uAlpha': 1.0,
      'uMaxY': model.mesh.boundingBox.yMax,
      'uMinY': model.mesh.boundingBox.yMin,
    };
  }

  double _t = 0.0;

  Map<String, dynamic> onDraw(World world, Model model, Renderer renderer) {
    _t += 0.016;
    double _red = (sin(_t) + 1) / 2;
    return {
      'uColor': new Vector3(_red, 1.0-_red, 0.5),
    };
  }

}