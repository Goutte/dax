part of dax;


class Texture {
  int get target;
  bool get isLoaded;
  ElementStream<Event> get onLoad;

  Texture();
}


class BitmapTexture extends Texture {

  ImageElement image;

  int get target => WebGL.TEXTURE_2D;
  bool get isLoaded => _isLoaded;
  ElementStream<Event> get onLoad => image.onLoad;

  bool _isLoaded = false;

  BitmapTexture(ImageElement this.image) {
    image.onLoad.listen((e){ _isLoaded = true; });
  }


}
