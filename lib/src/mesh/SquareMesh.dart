part of dax;


/**
 * An unit square mesh composed of two rectangular isoceles triangles,
 * ADB and CBD, in the Z=0 plane, centered on the origin, looking like this :
 *  A       B
 *  +-------+
 *  |     / |
 *  |   0   |
 *  | /     |
 *  +-------+
 *  D       C
 *
 * By default, a side of the square has length 1, (unitary square)
 * but you can provide a [size] to make it bigger or smaller.
 */
class SquareMesh extends TrianglesMesh {

  List<num> _vertices;

  List<num> get vertices => _vertices;

  SquareMesh({num size: 1.0}) {
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