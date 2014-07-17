part of dax;


/**
 *
 */
class BitmapTextureLayer extends MaterialLayer {

  String get glslFragment => """
uniform sampler2D uTexture;
uniform float uTextureScaleX;
uniform float uTextureScaleY;

varying vec2 vTextureCoords;

void main(void) {
    gl_FragColor *= texture2D(uTexture, vTextureCoords * vec2(uTextureScaleX, uTextureScaleY));
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

  BitmapTextureLayer(ImageElement this.image);

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