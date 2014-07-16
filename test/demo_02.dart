library dax_demo02;

import 'dart:math';
import 'dart:html';

import 'package:vector_math/vector_math.dart';
import 'package:stats/stats.dart';

import 'demo_utils.dart';
import '../lib/dax.dart';



/// ----------------------------------------------------------------------------

/**
 * A simple square model, that spins around its Y axis.
 */
class DemoSquareModel extends Model {
  Mesh _mesh = new SquareMesh();
  Mesh get mesh => _mesh;

  void update(num time, num delta) {
    rotate(delta*O/2000, unitY);
    setPosition(new Vector3(0.0, sin(time/200), 5*sin(time/900)));
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

  demo.startRendering();
  demo.startUpdating();

}
