library dax;

import 'dart:html';
import 'dart:web_gl' as WebGL;
import 'dart:typed_data';

import 'package:color/color.dart';
import 'package:vector_math/vector_math.dart';
import 'package:stats/stats.dart';

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

part 'src/layer/ColorLayer.dart';
part 'src/layer/PositionLayer.dart';
part 'src/layer/BitmapTextureLayer.dart';

part 'src/material/DefaultMaterial.dart';

part 'src/mesh/StupidTriangleMesh.dart';
part 'src/mesh/SquareMesh.dart';




/**
 * The circle constant, defined as the perimeter of the unit circle = 2*PI
 * See http://antoine.goutenoir.com/blog/2014/03/21/math-symbols-tau-pi-circle-constant/
 */
const double O = 6.2831853071795865;