part of dax;


/**
 * A quadcube is a quadrilateralized cube.
 *
 * As WebGL does not support quadrilateral faces, we need to split each sub-face
 * into two triangles. However, to make ~complex~ beautiful materials,
 * the topology of this splitting must be thought through, codified, and documented.
 * Right now, no order is guaranteed.
 *
 * UV mapping is homotilic : all tiles have the same UV mapping.
 *
 * By default, the [size] of a side of the quadcube has length 1. (unitary cube)
 */
class QuadcubeMesh extends TrianglesMesh {

  List<double> _vertices = [];
  List<double> _uvs = [];

  List<double> get vertices => _vertices;
  List<double> get uvs => _uvs;

  List<num> allSizes;
  List<int> allSegments;

  QuadcubeMesh({
      num size: 1.0,
      int segments: 1,
      num xSize,
      num ySize,
      num zSize,
      int xSegments,
      int ySegments,
      int zSegments
  }) {

    if (xSize == null) xSize = size;
    if (ySize == null) ySize = size;
    if (zSize == null) zSize = size;

    if (xSegments == null) xSegments = segments;
    if (ySegments == null) ySegments = segments;
    if (zSegments == null) zSegments = segments;

    allSizes = [ xSize, ySize, zSize ];
    allSegments = [ xSegments, ySegments, zSegments ];

    _buildCubeFace(new Vector3( 1.0, 0.0, 0.0));
    _buildCubeFace(new Vector3(-1.0, 0.0, 0.0));
    _buildCubeFace(new Vector3( 0.0, 1.0, 0.0));
    _buildCubeFace(new Vector3( 0.0,-1.0, 0.0));
    _buildCubeFace(new Vector3( 0.0, 0.0, 1.0));
    _buildCubeFace(new Vector3( 0.0, 0.0,-1.0));
  }

  /**
   * Build one of the 6 cube faces.
   */
  void _buildCubeFace(Vector3 faceAxis) {
    // find the offset by which we can rotate to have the axis as first component
    int offset = 0;
    for (int o in range(0,3)) {
      if (1 == faceAxis[o].abs()) offset = o;
    }

    List segments = new List.from(allSegments);
    List sizes = new List.from(allSizes);
    _applyCyclicRotation(segments, offset);
    _applyCyclicRotation(sizes, offset);


    num iSize = sizes[0], jSize = sizes[1], kSize = sizes[2];
    int jSegments = segments[1], kSegments = segments[2];

    // i is the face's constant
    num i = faceAxis[offset] * iSize / 2;

    num jStep = jSize / jSegments;
    num kStep = kSize / kSegments;

    Vector3 a = new Vector3.zero(), b = new Vector3.zero(),
            c = new Vector3.zero(), d = new Vector3.zero();
    for (int j in range(0,jSegments)) {
      for (int k in range(0,kSegments)) {
        // for each quadface (subface of the cube) aka rubuk's cube tile :)
        a.setValues(i, (j+0)*jStep - jSize/2, (k+0)*kStep - kSize/2);
        b.setValues(i, (j+1)*jStep - jSize/2, (k+0)*kStep - kSize/2);
        c.setValues(i, (j+1)*jStep - jSize/2, (k+1)*kStep - kSize/2);
        d.setValues(i, (j+0)*jStep - jSize/2, (k+1)*kStep - kSize/2);

        a.copyFromArray(_applyCyclicRotation(a.storage, -offset));
        b.copyFromArray(_applyCyclicRotation(b.storage, -offset));
        c.copyFromArray(_applyCyclicRotation(c.storage, -offset));
        d.copyFromArray(_applyCyclicRotation(d.storage, -offset));

        if (i > 0) {
          _buildQuadFace(a,b,c,d);
        } else {
          _buildQuadFace(c,b,a,d);
        }
      }
    }
  }

  /**
   *   Build one of the quadrilaterilized subfaces,
   *   by building two triangle faces ABD and CDB.
   *
   *   A     B
   *    +---+
   *    | / |
   *    +---+
   *   D     C
   */
  void _buildQuadFace(Vector3 a, Vector3 b, Vector3 c, Vector3 d) {
    // Vertices
    List<Vector3> verticesToAdd = [ a, b, d, /* & */  c, d, b ];
    for (Vector3 v in verticesToAdd) {
//      _vertices..add(v[0])..add(v[1])..add(v[2]);
      _vertices.addAll([v[0], v[1], v[2]]);
    }
    // UVs
    _uvs.addAll([0.0,0.0 , 1.0,0.0 , 0.0,1.0,
                 1.0,1.0 , 0.0,1.0 , 1.0,0.0]);
  }


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
  List _applyCyclicRotation(List tuple, int offset) {
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

}


/**
 * A quadsphere is a quadrilateralized spherical cube.
 * http://en.wikipedia.org/wiki/Quadrilateralized_spherical_cube
 *
 * It is a projection of a cube a onto its circumscribed sphere,
 * where the distortion of the tangential (gnomonic) projection
 * is compensated by a further curvilinear transformation.
 *
 * This makes it approximately equal-area, with no singularities at the poles.
 * Distortion is moderate over the entire sphere.
 *
 * UV mapping is homotilic : all tiles have the same UV mapping.
 *
 * By default, the [radius] of the quadsphere has length 1. (unitary sphere)
 */
class QuadsphereMesh extends QuadcubeMesh {

  List<double> _vertices = [];
  List<double> _uvs = [];

  List<double> get vertices => _vertices;
  List<double> get uvs => _uvs;

  QuadsphereMesh({
      num size: 1.0,
      int complexity: 3,
      num xSize,
      num ySize,
      num zSize,
      int xSegments,
      int ySegments,
      int zSegments
  }) : super(size: size, segments: complexity,
             xSize: xSize, ySize: ySize, zSize: zSize,
             xSegments: xSegments, ySegments: ySegments, zSegments: zSegments) {
    num xSize = allSizes[0], ySize = allSizes[1], zSize = allSizes[2];
    // Project parent's vertices on circumscribed sphere
    List<double> originalVertices = new List<double>.from(_vertices);
    _vertices.clear();
    for (int i in range(0, originalVertices.length, 3)) {

      double x = originalVertices[i+0] * 2 / xSize;
      double y = originalVertices[i+1] * 2 / ySize;
      double z = originalVertices[i+2] * 2 / zSize;

      double dx = x * sqrt(1.0 - (y*y)/2.0 - (z*z/2.0) + (y*y*z*z/3.0)) * xSize/2.0;
      double dy = y * sqrt(1.0 - (z*z)/2.0 - (x*x/2.0) + (z*z*x*x/3.0)) * ySize/2.0;
      double dz = z * sqrt(1.0 - (x*x)/2.0 - (y*y/2.0) + (x*x*y*y/3.0)) * zSize/2.0;

      _vertices.add(dx);
      _vertices.add(dy);
      _vertices.add(dz);
    }
  }

}