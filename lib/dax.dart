library dax;

import 'dart:math';
import 'dart:html';
import 'dart:collection';
import 'dart:web_gl' as WebGL;
import 'dart:typed_data';

import 'package:color/color.dart';
import 'package:vector_math/vector_math.dart';
import 'package:stats/stats.dart';
import 'package:game_loop/game_loop_html.dart';
import "package:range/range.dart";

part 'src/core/Camera.dart';
part 'src/core/Controller.dart';
part 'src/core/GlslVocabulary.dart';
part 'src/core/Material.dart';
part 'src/core/MaterialLayer.dart';
part 'src/core/Mesh.dart';
part 'src/core/Model.dart';
part 'src/core/Renderable.dart';
part 'src/core/Renderer.dart';
part 'src/core/SceneGraph.dart';
part 'src/core/SceneNode.dart';
part 'src/core/Shader.dart';
part 'src/core/ShaderProgram.dart';
part 'src/core/SpatialSceneNode.dart';
part 'src/core/Texture.dart';
part 'src/core/WebGLRenderer.dart';
part 'src/core/World.dart';

part 'src/error/WebGLException.dart';
part 'src/error/ShaderError.dart';

part 'src/layer/ColorLayer.dart';
part 'src/layer/PositionLayer.dart';
part 'src/layer/BitmapTextureLayer.dart';
part 'src/layer/DidiLayer.dart';
part 'src/layer/StarLayer.dart';
part 'src/layer/WoodLayer.dart';

part 'src/material/DefaultMaterial.dart';

part 'src/mesh/StupidTriangleMesh.dart';
part 'src/mesh/SquareMesh.dart';
part 'src/mesh/QuadsphereMesh.dart';




/**
 * The circle constant, defined as the perimeter of the unit circle = 2*PI
 * See http://antoine.goutenoir.com/blog/2014/03/21/math-symbols-tau-pi-circle-constant/
 */
const double O = 6.2831853071795865;


/**
 * Mutates the [tuple] by rotating [offset] to the left, and then returns it.
 * The rotation is a circular one, meaning that during one step to the left,
 * the first element becomes the last element. The [offset] may be negative,
 * and in that case it will rotate to the right.
 *
 * Examples :
 *     tuple     off
 *   (0,1,2,3) ,  0  -> (0,1,2,3) # useless
 *   (0,1,2,3) ,  1  -> (1,2,3,0)
 *   (0,1,2,3) ,  2  -> (2,3,0,1)
 *   (0,1,2,3) , -1  -> (3,0,1,2)
 */
List rotateCycle(List tuple, int offset) {
  int n = tuple.length;
  offset = ((offset % n) + n) % n;
  int tmp;
  while (offset-- > 0) {
    tmp = tuple[0];
    for (int i in range(0, n-1)) {
      tuple[i] = tuple[i+1];
    }
    tuple[n-1] = tmp;
  }

  return tuple;
}