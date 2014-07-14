part of dax;


/**
 * A Model owns a Mesh that holds geometrical information.
 * Responsibilities:
 *   - generate the [vertices] to provide to the gl context during render.
 * You can implement this however you want.
 */
abstract class Mesh {

  int drawMode = WebGL.POINTS;

  /// API ----------------------------------------------------------------------

  /// A flat list of [vertices]'s coordinates.
  List<double> get vertices;

  /// The number of above [vertices], depending on [drawMode].
  int get verticesCount;

}


/**
 * A base mesh for GL_TRIANGLES meshes.
 */
abstract class TrianglesMesh extends Mesh {

  int drawMode = WebGL.TRIANGLES;

  int get verticesCount => (vertices.length / 3).toInt();

}


// todo: TrianglesStripMesh and TrianglesFanMesh.
