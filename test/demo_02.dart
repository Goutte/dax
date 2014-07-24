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
 * Notice the BitmapTextureLayer
 */
class DemoGobanMaterial extends Material {
  DemoGobanMaterial() : super() {
    layers.add(new PositionLayer());
//    layers.add(new ColorLayer());
    layers.add(new DidiLayer());
    layers.add(new WoodLayer());
//    layers.add(new StarLayer());
//    layers.add(new BitmapTextureLayer(new ImageElement(src: "texture/goban_lines.png")));
  }
}

/**
 * A simple material that loads the image `texture/goutte.png` as texture.
 * Notice the BitmapTextureLayer
 */
class Demo02Material01 extends Material {
  Demo02Material01() : super() {
    layers.add(new PositionLayer());
    layers.add(new ColorLayer());
    layers.add(new StarLayer());
//    layers.add(new BitmapTextureLayer(new ImageElement(src: "texture/brain.png")));
  }
}

/**
 * A simple material that loads the image `texture/brain.png` as texture.
 * It demoes the sweeter BitmapTextureLayer.src() factory.
 *
 * About PNG textures :
 * - nothing:
 * - background:
 * - color:
 * - background and color:
 */
class Demo02Material02 extends Material {
  Demo02Material02() : super() {
    layers.add(new PositionLayer());
    layers.add(new ColorLayer());
    ///
    layers.add(new BitmapTextureLayer.src("texture/background_and_color.png"));
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
    rotate(delta*O/13, unitY);
    setPosition(new Vector3(sin(time/10+O/2), 0.0, cos(time/10+O/2)));
  }
}

/**
* A simple square model, spinning. (?)
*/
class DemoSquareModel02 extends Model {
  Mesh _mesh = new SquareMesh();
  Mesh get mesh => _mesh;

  Material material = new Demo02Material02();

  void update(num time, num delta) {
//    rotate(delta*O/3000, unitY);
//    setPosition(new Vector3(cos(time/900), sin(time/900), 0.0));
    rotate(delta*O/24, unitY);
    rotate(delta*O/42, unitZ);
    rotate(delta*O/42, unitX);
    setPosition(new Vector3(sin(time/10), 0.0, cos(time/10)));
  }
}

class DemoGobanModel extends Model {
  Mesh _mesh = new QuadsphereMesh(complexity: 9, size: 10.0);
  Mesh get mesh => _mesh;
  Material material = new DemoGobanMaterial();
  void update(num time, num delta) {
    rotate(-delta*O/84, unitY);
  }
}

/**
 * We define our Demo Controller that will set up the world's models.
 */
class Demo02 extends Controller {
  Demo02(CanvasElement canvas, Stats stats) : super(canvas, stats: stats) {
    world.add(new DemoGobanModel());
    world.add(new DemoSquareModel());
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

  demo.gl.enable(DEPTH_TEST);
  demo.gl.blendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA);
  demo.gl.enable(BLEND);

  demo.start();

//  demo.startRendering();
//  demo.startUpdating();

//  demo.

  //demo.onUpdate = update;
//  demo.onRender = render;
//  demo.onResize = resize;
//  resize(demo);


}
