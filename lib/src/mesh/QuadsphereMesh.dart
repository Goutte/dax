part of dax;


/**
 * A quadsphere is a quadrilateralized spherical cube.
 * http://en.wikipedia.org/wiki/Quadrilateralized_spherical_cube
 *
 * It is a tangential (gnomonic) projection of a quadrilateralized cube onto its
 * circumscribed sphere, where the distortion of the projection
 * is compensated by a further curvilinear transformation.
 * This makes it approximately equal-area, with no singularities at the poles.
 * Distortion is moderate over the entire sphere.
 *
 * UV mapping is inherited from parent QuadcubeMesh.
 *
 * todo: By default, the [radius] of the quadsphere has length 1. (unitary sphere)
 */
class QuadsphereMesh extends QuadcubeMesh {

  List<double> _vertices = [];

  List<double> get vertices => _vertices;

  QuadsphereMesh({
      num size: 1.0,
      int complexity: 3,
      num xSize,
      num ySize,
      num zSize,
      int xSegments,
      int ySegments,
      int zSegments,
      OnQuadFace onQuadFace
  }) : super(size: size, segments: complexity,
             xSize: xSize, ySize: ySize, zSize: zSize,
             xSegments: xSegments, ySegments: ySegments, zSegments: zSegments,
             onQuadFace: onQuadFace) {
    num xSize = allSizes[0], ySize = allSizes[1], zSize = allSizes[2];
    // Project parent's vertices on circumscribed sphere
    List<double> originalVertices = new List<double>.from(_vertices);
    projectCubeOnQuadsphere(originalVertices, _vertices, xSize: xSize, ySize: ySize, zSize: zSize);
  }

  /**
   * Accepts flat lists of vertices coordinates.
   */
  static void projectCubeOnQuadsphere(List<double> inVertices,
                                      List<double> outVertices,
                                      {xSize:1.0, ySize:1.0, zSize:1.0}) {
    outVertices.clear();
    for (int i in range(0, inVertices.length, 3)) {

      double x = inVertices[i+0] * 2 / xSize;
      double y = inVertices[i+1] * 2 / ySize;
      double z = inVertices[i+2] * 2 / zSize;

      double dx = x * sqrt(1.0 - (y*y)/2.0 - (z*z/2.0) + (y*y*z*z/3.0)) * xSize/2.0;
      double dy = y * sqrt(1.0 - (z*z)/2.0 - (x*x/2.0) + (z*z*x*x/3.0)) * ySize/2.0;
      double dz = z * sqrt(1.0 - (x*x)/2.0 - (y*y/2.0) + (x*x*y*y/3.0)) * zSize/2.0;

      outVertices.add(dx);
      outVertices.add(dy);
      outVertices.add(dz);
    }
  }

}