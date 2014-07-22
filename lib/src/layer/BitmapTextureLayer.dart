part of dax;


/**
 * Supported:
 * - Power of 2 sized [image]
 * - Factory BitmapTextureLayer.src
 */
class BitmapTextureLayer extends MaterialLayer {

  String get glslFragment => """
uniform sampler2D uTexture;
uniform float uTextureScaleX;
uniform float uTextureScaleY;

varying vec2 vTextureCoords;

void main(void) {
    vec4 t = texture2D(uTexture, vTextureCoords * vec2(uTextureScaleX, uTextureScaleY));
    float srcAlpha = t[3];
    float dstAlpha = gl_FragColor[3];
    if (srcAlpha == 1.0) {
      gl_FragColor[0] = t[0]; // R
      gl_FragColor[1] = t[1]; // G
      gl_FragColor[2] = t[2]; // B
      gl_FragColor[3] = t[3]; // A
//    } else if (dstAlpha == 1.0) {
//      gl_FragColor[0] = t[0]; // R
//      gl_FragColor[1] = t[1]; // G
//      gl_FragColor[2] = t[2]; // B
//      gl_FragColor[3] = t[3]; // A
    } else {
      gl_FragColor[0] = gl_FragColor[0] * t[0]; // R
      gl_FragColor[1] = gl_FragColor[1] * t[1]; // G
      gl_FragColor[2] = gl_FragColor[2] * t[2]; // B
      gl_FragColor[3] = 1.0 - (1.0 - gl_FragColor[3]) * (1.0 - t[3]); // alpha
    }

}
  """;
  String get glslVertex => """
attribute vec2 VERTEX_TEXTURE_COORDS;

varying vec2 vTextureCoords;

void main(void) {
    vTextureCoords = VERTEX_TEXTURE_COORDS;
}
  """;

  ImageElement image;

  BitmapTextureLayer(ImageElement this.image) : super();

  /**
   * @NotSure. Also fromPng() fromFilepath()
   * Example usage :
   *   layers.add(new BitmapTextureLayer.src("texture/bricks.png");
   */
  factory BitmapTextureLayer.src(String src) {
    ImageElement image = new ImageElement(src: src);
    return new BitmapTextureLayer(image);
  }


  Map<String, dynamic> onSetup(World world, Model model, Renderer renderer) {
    return {
        'uTexture': new BitmapTexture(image),
        'uTextureScaleX': 1.0,
        'uTextureScaleY': 1.0,
        'VERTEX_TEXTURE_COORDS': model.mesh.uvs,
    };
  }

  Map<String, dynamic> onDraw(World world, Model model, Renderer renderer) {
    return {};
  }

}