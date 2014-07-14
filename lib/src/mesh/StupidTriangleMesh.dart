part of dax;


/**
 * A stupid triangle mesh, used for testing.
 */
class StupidTriangleMesh extends TrianglesMesh {

  List<double> _vertices;

  List<double> get vertices => _vertices;

  StupidTriangleMesh() {
    _vertices = [
         0.0,  1.0,  0.0,
        -1.0, -1.0,  0.0,
         1.0, -1.0,  0.0,
    ];
  }

}

