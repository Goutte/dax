part of dax;


/**
 * A Mesh belongs to a Model and holds geometrical and texturing information.
 * Responsibilities:
 *   - generate the [vertices] to provide to the gl context during render.
 *   - generate the [uvs] to provide to the gl context during render of texture.
 * You can implement this however you want.
 */
abstract class Mesh {

  int drawMode = WebGL.POINTS;

  /// API ----------------------------------------------------------------------

  /// A flat list of [vertices]'s coordinates.
  List<double> get vertices;

  /// The number of above [vertices], depending on [drawMode].
  int get verticesCount;

  /// A flat list of [uvs] coordinates, to use with the TextureLayer.
  /// Each coordinate element is between 0 and 1, the origin being top left.
  /// If this is left null, the TextureLayer will raise an Error if used.
  List<double> get uvs => null;

}


/**
 * A base mesh for GL_TRIANGLES meshes.
 */
abstract class TrianglesMesh extends Mesh {

  int drawMode = WebGL.TRIANGLES;

  int get verticesCount => (vertices.length / 3).toInt();

}


// todo: TrianglesStripMesh and TrianglesFanMesh.
