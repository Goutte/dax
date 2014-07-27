library dax_demo02;

import 'dart:math';
import 'dart:html';
import 'dart:web_gl';

import 'package:vector_math/vector_math.dart';
import 'package:stats/stats.dart';
import 'package:color/color.dart';

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
    layers.add(new BitmapTextureLayer(new ImageElement(src: "texture/quadsphere/debug_example.png")));
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
    layers.add(new StarLayer(
        glowColor: new Vector3(0.1, 0.35, 0.8),
        fireColor: new Vector3(0.3, 0.65, 0.8)
    ));
  }
}

/**
 * A model of a quadspherical goban
 */
class DemoGobanModel extends Model {
  Mesh _mesh = new QuadsphereMesh(complexity: 9, size: 1.0, ySegments: 19);
  Mesh get mesh => _mesh;
  Material material = new DemoGobanMaterial();
  void update(num time, num delta) {
    rotate(-delta*O/84, unitY);
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
    rotate(delta*O/24, unitY);
    rotate(delta*O/42, unitZ);
    rotate(delta*O/42, unitX);
    setPosition(new Vector3(sin(time/10), 0.0, cos(time/10)));
  }
}

/**
 * We define our Demo Controller that will set up the world's models.
 */
class Demo02 extends Controller {
  Model goban;
  Demo02(CanvasElement canvas, Stats stats) : super(canvas, stats: stats) {
    goban = new DemoGobanModel();
    world.add(goban);
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

  Demo02 demo = new Demo02(canvas, stats);

  demo.world.camera.setPosition(new Vector3(0.0,0.0,2.2666));

  demo.gl.enable(DEPTH_TEST);
  demo.gl.blendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA);
  demo.gl.enable(BLEND);

  demo.start();


  /// Allow change of the texture of the quadsphere on-the-fly.
  querySelector("#texture_file").onChange.listen((e){
    File file = e.currentTarget.files[0];
    print("Changed texture file to ${file.name}");
    ImageElement tex = new ImageElement();
    FileReader reader = new FileReader();
    reader.onLoad.listen((e) {
      tex.src = reader.result;
      demo.goban.material.setVariable('BitmapTextureLayer', 'uTexture', new BitmapTexture(tex));
    });
    reader.readAsDataUrl(file);
  });


  // Oddly enough, drag'n drop of external files does not work on my machine
  // Even gmail's does not.
//  canvas.onDrop.listen((e){
//    print('dropped $e');
//  });
//
//  canvas.onDragEnd.listen((e){
//    print('drag end $e');
//  });
//
//  canvas.onDragEnter.listen((e){
//    e.stopPropagation();
//    e.preventDefault();
//    print('drag enter $e');
//  });
//
//  canvas.onDragOver.listen((e){
//    e.stopPropagation();
//    e.preventDefault();
//  });
//
//  canvas.onDragLeave.listen((e){
//    e.stopPropagation();
//    e.preventDefault();
//    print('drag leave $e');
//  });



}
