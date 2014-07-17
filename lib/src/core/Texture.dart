part of dax;


class Texture {
  Texture();
}


class BitmapTexture extends Texture {

  ImageElement image;

  int get target => WebGL.TEXTURE_2D;

  BitmapTexture(ImageElement this.image);

  /**
   * Upload the texture bitmap data to the GPU.
   */
  void upload(WebGL.RenderingContext gl, WebGL.Texture handle) {
    try {
      gl.texImage2D(target, 0, WebGL.RGBA, WebGL.RGBA, WebGL.UNSIGNED_BYTE, image);
    } catch (e) {
      print('Failed to upload the texture data to the GPU : ${e}');
    }
  }

}
