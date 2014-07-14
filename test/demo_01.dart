library dax_demo;

import 'dart:math';
import 'dart:html';
import 'dart:web_gl';
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';
import 'package:stats/stats.dart';

import '../lib/dax.dart';



/// ----------------------------------------------------------------------------


class SingleTriangleModel extends Model {

  Mesh _mesh;
  Material _material;

  Mesh get mesh => _mesh;
  Material get material => _material;

  SingleTriangleModel() {
    _mesh = new StupidTriangleMesh();
    _material = new DefaultMaterial();
  }

}

class UnitSquareModel extends Model {

  Mesh _mesh;
  Material _material;

  Mesh get mesh => _mesh;
  Material get material => _material;

  UnitSquareModel() {
    _mesh = new UnitSquareMesh();
    _material = new DefaultMaterial();
  }

}


/// ----------------------------------------------------------------------------

main() {

  CanvasElement canvas = querySelector("#demoCanvas");
  Map urlParameters = parseQueryString();

  Stats stats = new Stats();
  bool trackFrameRate = urlParameters.containsKey("fps");
  if (trackFrameRate) {
    querySelector("#showStatsButton").remove();
    document.body.children.add(stats.container);
  } else {
  }

  // Get the WebGL RenderingContext from CanvasElement
  RenderingContext gl = canvas.getContext3d(
    alpha: true, depth: true, stencil: false,
    antialias: true, premultipliedAlpha: true,
    preserveDrawingBuffer: false
  );

  // Set up the world
  WebGLRenderer renderer = new WebGLRenderer(gl);
  World world = new World();

  Model triangle = new SingleTriangleModel();
  world.add(triangle);

  Model square = new UnitSquareModel();
  world.add(square);

  // Make the square blue
  square.material.setLayerVariable('ColorLayer', 'uColor', [0.0, 0.0, 1.0]);
  square.material.setLayerVariable('ColorLayer', 'uAlpha', 0.5);

  // this is automatically set -- bind this to onResize
  // gl.viewport(0, 0, canvas.width, canvas.height);

  // These are the default values
  // gl.enable(DEPTH_TEST);
  // gl.disable(BLEND);

//  gl.disable(DEPTH_TEST);
  gl.blendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA);
  gl.enable(BLEND);



  draw(time) {
    window.animationFrame.then(draw);

    if (trackFrameRate) {
      stats.begin();
    }

    renderer.draw(world);

    square.rotate(O/1200, new Vector3(1.0,0.0,0.0));
    triangle.rotate(-O/800, new Vector3(0.0,1.0,0.0));

    if (trackFrameRate) {
      stats.end();
    }
  }

  draw(0);

}



/// UTILS ----------------------------------------------------------------------

/**
 * Parse and store the URL parameters for start up.
 */
Map parseQueryString() {
  Map urlParameters = {};
  String search = window.location.search;
  if (search.startsWith("?")) {
    search = search.substring(1);
  }
  List<String> params = search.split("&");
  for (String param in params) {
    List<String> pair = param.split("=");
    if (pair.length == 1) {
      urlParameters[pair[0]] = "";
    } else {
      urlParameters[pair[0]] = pair[1];
    }
  }

  return urlParameters;
}