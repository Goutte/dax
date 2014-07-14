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
  List<num> get vertices;

  /// The number of above [vertices], depending on [drawMode].
  int get verticesCount;

}


abstract class TrianglesMesh extends Mesh {

  int drawMode = WebGL.TRIANGLES;

  int get verticesCount => (vertices.length / 3).toInt();

}


/**
 * A stupid triangle mesh, used for testing.
 */
class StupidTriangleMesh extends TrianglesMesh {

  List<num> _vertices;

  List<num> get vertices => _vertices;

  StupidTriangleMesh() {
    _vertices = [
         0.0,  1.0,  0.0,
        -1.0, -1.0,  0.0,
         1.0, -1.0,  0.0,
    ];
  }

}


/**
 * A square mesh composed of two rectangular isoceles triangles,
 * ADB and CBD, in the Z=0 plane, centered on the origin, looking like this :
 *  A       B
 *  +-------+
 *  |     / |
 *  |   0   |
 *  | /     |
 *  +-------+
 *  D       C
 *
 * By default, a side of the square has length 1. (unitary square)
 */
class UnitSquareMesh extends TrianglesMesh {

  List<num> _vertices;

  List<num> get vertices => _vertices;

  UnitSquareMesh({num size: 1.0}) {
    _vertices = [
        -0.5,  0.5,  0.0, // A
        -0.5, -0.5,  0.0, // D
         0.5,  0.5,  0.0, // B

         0.5, -0.5,  0.0, // C
         0.5,  0.5,  0.0, // B
        -0.5, -0.5,  0.0, // D
    ];
    _vertices = new List<num>.generate(_vertices.length,
        (int index) => _vertices[index] * size);
  }

}