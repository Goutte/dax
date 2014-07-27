part of dax;

const int MAPPING_HOMOTILIC = 0x01;
const int MAPPING_CUBIC_NET = 0x02;

/**
 * A quadcube is a quadrilateralized cube.
 *
 * As WebGL does not support quadrilateral faces, we need to split each sub-face
 * into two triangles. However, to make ~complex~ beautiful materials,
 * the topology of this splitting must be thought through, codified, and documented.
 * Right now, no order is guaranteed.
 *
 * About UV mapping :
 * - Homotilic : all tiles have the same UV mapping on the same texture.
 * - Cubic Net : like a christian cross laid on its left side.
 *
 * About events :
 * So that you may hook your coordinates system
 *
 * By default, the [size] of a side of the quadcube has length 1. (unitary cube)
 */
class QuadcubeMesh extends TrianglesMesh {

  List<double> _vertices = [];
  List<double> _uvs = [];
  List<double> _uvs_homotilic = [];
  List<double> _uvs_cubic_net = [];

  List<double> get vertices => _vertices;
  List<double> get uvs => _getUvs();

  List<num> allSizes;
  List<int> allSegments;

  int uvMapping;

  // This does not behave as I expected it to.
  // I cannot use it as the default of constructor parameter [uvMapping].
//  static final int MAPPING_HOMOTILIC = 0x01;
//  static final int MAPPING_CUBIC_NET = 0x02;

  QuadcubeMesh({
      num size: 1.0,
      int segments: 1,
      num xSize,
      num ySize,
      num zSize,
      int xSegments,
      int ySegments,
      int zSegments,
      int uvMapping: MAPPING_CUBIC_NET
  }) {

    this.uvMapping = uvMapping;

    if (xSize == null) xSize = size;
    if (ySize == null) ySize = size;
    if (zSize == null) zSize = size;

    if (xSegments == null) xSegments = segments;
    if (ySegments == null) ySegments = segments;
    if (zSegments == null) zSegments = segments;

    allSizes = [ xSize, ySize, zSize ];
    allSegments = [ xSegments, ySegments, zSegments ];

    _buildCubeFace(new Vector3( 1.0, 0.0, 0.0), new Vector2(3/4, 2/3), new Vector2(2/4, 1/3), true); // +X
    _buildCubeFace(new Vector3(-1.0, 0.0, 0.0), new Vector2(0/4, 2/3), new Vector2(1/4, 1/3), true); // -X
    _buildCubeFace(new Vector3( 0.0, 1.0, 0.0), new Vector2(1/4, 0/3), new Vector2(2/4, 1/3), true); // +Y
    _buildCubeFace(new Vector3( 0.0,-1.0, 0.0), new Vector2(1/4, 3/3), new Vector2(2/4, 2/3), true); // -Y
    _buildCubeFace(new Vector3( 0.0, 0.0, 1.0), new Vector2(1/4, 2/3), new Vector2(2/4, 1/3), false); // +Z
    _buildCubeFace(new Vector3( 0.0, 0.0,-1.0), new Vector2(4/4, 2/3), new Vector2(3/4, 1/3), false); // -Z
  }

  /// TO OVERRIDE --------------------------------------------------------------

  /**
   * Override this to hook your coordinates system on the quadfaces.
   * Ideally this would be a Stream for us to subscribe on.
   * It is provided the [index] of the first coordinate element of
   * the first vertex (A) of the quadface.
   * It is also provided a list of 3 integers that can act as coordinates
   * suitable for lattice operations and analysis such as neighboring,
   * pathfinding, pole recognition, etc.
   * (these operations are not provided by dax, they are examples)
   * (also, there should be other hooks, for coordinate systems on edges
   * or vertices.
   */
  void onQuadFace(int index, List<int> systemCoords) {}

  /// PRIVVIES -----------------------------------------------------------------

  List<double> _getUvs() {
    if (uvMapping & MAPPING_CUBIC_NET > 0) {
      return _uvs_cubic_net;
    } else {
      return _uvs_homotilic;
    }
  }

  /**
   * Builds one of the 6 cube faces, specifically the one orthogonal to the
   * oriented [faceAxis].
   * 
   * When using MAPPING_CUBIC_NET :
   * It also takes care of the UVs, and will map this
   * face to the square at [uvOrigin] in the [MAPPING_CUBIC_NET].
   * [uvMin] is the UV coordinates of the smallest (minimal) vertices of the
   * face, those in the top-left corner of a classic 2D referential.
   * The cube face will have as texture the square between [uvMin] and [uvMax].
   *
   * Unsure about the usage of Vector2, a simple Set might be enough and lighter.
   */
  void _buildCubeFace(Vector3 faceAxis, Vector2 uvMin, Vector2 uvMax, bool inverse) {
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
    int iSegmts = segments[0], jSegmts = segments[1], kSegmts = segments[2];

    // Data about integer system coordinates
    int iSys = faceAxis[offset].toInt() * iSegmts;
    int jSys, kSys;

    // Data about vertices coordinates (affected by sizes)
    num i = faceAxis[offset] * iSize / 2; // i is the face's constant
    num jStep = jSize / jSegmts;
    num kStep = kSize / kSegmts;
    num juvMin = uvMin[0], juvMax = uvMax[0];
    num kuvMin = uvMin[1], kuvMax = uvMax[1];
    num jjuvStep = (juvMax - juvMin) / jSegmts;
    num jkuvStep = (juvMax - juvMin) / kSegmts;
    num kkuvStep = (kuvMax - kuvMin) / kSegmts;
    num kjuvStep = (kuvMax - kuvMin) / jSegmts;

    // The integer coordinates
    List<int> sysCoords = new List<int>();
    // The vertices
    Vector3 a = new Vector3.zero(), b = new Vector3.zero(),
            c = new Vector3.zero(), d = new Vector3.zero();
    // Their respective UVs
    Vector2 auv = new Vector2.zero(), buv = new Vector2.zero(),
            cuv = new Vector2.zero(), duv = new Vector2.zero();
    for (int j in range(0, jSegmts)) {
      for (int k in range(0, kSegmts)) {
        /**
         * for each quadface (subface of the cube) aka rubik's cube tile :)
         * I is towards your eye, and the rest looks like :
         *      K
         *      ↑
         *   D     C
         *    +---+
         *    | / |  → J
         *    +---+
         *   A     B
         */
        sysCoords.clear();
        jSys = j * 2 - jSegmts + 1;
        kSys = k * 2 - kSegmts + 1;
        sysCoords.addAll([iSys, jSys, kSys]);
//        sysCoords[0] = iSys; sysCoords[1] = jSys; sysCoords[2] = kSys;
        _applyCyclicRotation(sysCoords, -offset);

        a.setValues(i, (j+0)*jStep - jSize/2, (k+0)*kStep - kSize/2);
        b.setValues(i, (j+1)*jStep - jSize/2, (k+0)*kStep - kSize/2);
        c.setValues(i, (j+1)*jStep - jSize/2, (k+1)*kStep - kSize/2);
        d.setValues(i, (j+0)*jStep - jSize/2, (k+1)*kStep - kSize/2);

        a.copyFromArray(_applyCyclicRotation(a.storage, -offset));
        b.copyFromArray(_applyCyclicRotation(b.storage, -offset));
        c.copyFromArray(_applyCyclicRotation(c.storage, -offset));
        d.copyFromArray(_applyCyclicRotation(d.storage, -offset));

        if (inverse) { // when x/y of uv mapping does not match j/k
          auv.setValues(juvMin + (k+0)*jkuvStep, kuvMin + (j+0)*kjuvStep);
          buv.setValues(juvMin + (k+0)*jkuvStep, kuvMin + (j+1)*kjuvStep);
          cuv.setValues(juvMin + (k+1)*jkuvStep, kuvMin + (j+1)*kjuvStep);
          duv.setValues(juvMin + (k+1)*jkuvStep, kuvMin + (j+0)*kjuvStep);
        } else {
          auv.setValues(juvMin + (j+0)*jjuvStep, kuvMin + (k+0)*kkuvStep);
          buv.setValues(juvMin + (j+1)*jjuvStep, kuvMin + (k+0)*kkuvStep);
          cuv.setValues(juvMin + (j+1)*jjuvStep, kuvMin + (k+1)*kkuvStep);
          duv.setValues(juvMin + (j+0)*jjuvStep, kuvMin + (k+1)*kkuvStep);
        }

        int quadFaceIndex = _vertices.length;

        _buildQuadFace(a,b,c,d,auv,buv,cuv,duv);

        onQuadFace(quadFaceIndex, sysCoords);
      }
    }
  }

  /**
   * Build one of the quadrilaterilized subfaces,
   * by building two triangle faces ABC and CDA.
   *
   * Wondering about addAll() : need some benchmarking tools.
   */
  void _buildQuadFace(Vector3 a, Vector3 b, Vector3 c, Vector3 d,
                      Vector2 auv, Vector2 buv, Vector2 cuv, Vector2 duv) {
    // Vertices
    List<Vector3> verticesToAdd = [ a, b, c, /* & */  c, d, a ];
    for (Vector3 v in verticesToAdd) {
//      _vertices..add(v[0])..add(v[1])..add(v[2]);  // should work, yet it does not ?
      _vertices.addAll([v[0], v[1], v[2]]);
    }
    // UVs - Homotilic
    _uvs_homotilic.addAll([0.0,0.0 , 1.0,0.0 , 0.0,1.0,
                           1.0,1.0 , 0.0,1.0 , 1.0,0.0]);
    // UVs - Cubic Net
    for (Vector2 v in [ auv, buv, cuv, /* & */  cuv, duv, auv ]) {
      _uvs_cubic_net.addAll([v[0], v[1]]);
    }
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
   *
   * To add to yet another math lib ? Tree-shaking means we can make that one
   * bigass lib with everything about maths, not just webgl. Look for it.
   */
  List _applyCyclicRotation(List tuple, int offset) {
    int n = tuple.length;
    offset = ((offset % n) + n) % n;
    num tmp;
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

