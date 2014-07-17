library dax_demo02;

import 'dart:math';
import 'dart:html';
import 'dart:web_gl';

import 'package:vector_math/vector_math.dart';
import 'package:stats/stats.dart';

import 'demo_utils.dart';
import '../lib/dax.dart';



/// ----------------------------------------------------------------------------

/**
 * A simple material that loads the image `texture/goutte.png` as texture.
 */
class Demo02Material01 extends Material {
  Demo02Material01() : super() {
    layers.add(new PositionLayer());
    layers.add(new ColorLayer());
    layers.add(new BitmapTextureLayer(new ImageElement(src: "texture/goutte.png")));
  }
}

/**
 * A simple material that loads the image `texture/brain.png` as texture.
 */
class Demo02Material02 extends Material {
  Demo02Material02() : super() {
    layers.add(new PositionLayer());
    layers.add(new ColorLayer());
    layers.add(new BitmapTextureLayer(new ImageElement(src: "texture/brain.png")));
  }
}

/**
 * A simple square model, that spins around its Y axis.
 */
class DemoSquareModel extends Model {
  Mesh _mesh = new SquareMesh();
  Mesh get mesh => _mesh;

  Material material = new Demo02Material01();

  void update(num time, num delta) {
    rotate(delta*O/2000, unitY);
    setPosition(new Vector3(0.0, sin(time/200), 5*sin(time/900)));
  }
}

/**
 * A simple square model, that rotates around the Y axis.
 */
class DemoSquareModel02 extends Model {
  Mesh _mesh = new SquareMesh();
  Mesh get mesh => _mesh;

  Material material = new Demo02Material02();

  void update(num time, num delta) {
    rotate(delta*O/3000, unitY);
    setPosition(new Vector3(cos(time/900), sin(time/900), 0.0));
  }
}

/**
 * We define our Demo Controller that will set up the world's models.
 */
class Demo02 extends Controller {
  Model square;

  Demo02(CanvasElement canvas, Stats stats) : super(canvas, stats: stats) {
    square = new DemoSquareModel();
    world.add(square);
    world.add(new DemoSquareModel02());
  }
}

/// ----------------------------------------------------------------------------

main() {

  CanvasElement canvas = querySelector("#demoCanvas");
  Map urlParameters = parseQueryString();

  Stats stats;
  bool trackFrameRate = urlParameters.containsKey("fps");
  if (trackFrameRate) {
    stats = new Stats();
    querySelector("#showStatsButton").remove();
    document.body.children.add(stats.container);
  }

  Controller demo = new Demo02(canvas, stats);

  demo.gl.blendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA);
  demo.gl.enable(BLEND);

  demo.startRendering();
  demo.startUpdating();


}
