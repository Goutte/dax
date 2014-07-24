part of dax;

/**
 * For a mesh, the smallest circumscribed box whose faces are othogonal
 * to one of the axes. There may be smaller boxes with rotations, but we
 * do not care about that here. Maybe for `SmallestBoundingBox` ?
 */
class BoundingBox {

//  @left   = vec3.create()
//  @right  = vec3.create()
//  @top    = vec3.create()
//  @bottom = vec3.create()
//  @front  = vec3.create()
//  @back   = vec3.create()
//  @center = vec3.create()
//  @width  = 0
//  @height = 0
//  @depth  = 0

  double xMin = 0.0;
  double xMax = 0.0;
  double yMin = 0.0;
  double yMax = 0.0;
  double zMin = 0.0;
  double zMax = 0.0;

  void expandToIncludeX(double x) {
    if (x < xMin) xMin = x;
    if (x > xMax) xMax = x;
  }

  void expandToIncludeY(double y) {
    if (y < yMin) yMin = y;
    if (y > yMax) yMax = y;
  }

  void expandToIncludeZ(double z) {
    if (z < zMin) zMin = z;
    if (z > zMax) zMax = z;
  }

  void expandToInclude(Vector3 point) {
    expandToIncludeX(point.x);
    expandToIncludeY(point.y);
    expandToIncludeZ(point.z);
  }



}


/**
 * Vertices iterator as Vector3 for draw modes POINT and TRIANGLES.
 * It reads the draw-ready vertices flat list and iterates over Vector3.
 * Will (ig) not work with TRIANGLE_STRIP and TRIANGLE_FAN, but they can have their own.
 */
class MeshVerticesIterator implements Iterator {
  bool _hasMoved = false;
  int _current = 0;
  int _total;

  List<double> vertices;

  MeshVerticesIterator(List<double> this.vertices) {
    _total = vertices.length;
  }

  Vector3 get current => _getCurrent();

  Vector3 _getCurrent() {
    if (_hasMoved) {
      if (_canReadCurrent()) {
        return new Vector3(
            vertices[_current  ],
            vertices[_current+1],
            vertices[_current+2]
        );
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  bool _canReadCurrent() {
    return (_current + 2 < _total);
  }

  bool moveNext() {
    if ((!_hasMoved) && _canReadCurrent()) {
      _hasMoved = true;
      return true;
    }
    // we ignore the values if there's less than 3 left.
    if (_canReadCurrent()) {
      _current += 3;
      if (_canReadCurrent()) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}

/**
 * May provide different types for other draw modes here ?
 */
class VerticesCollectionFromFlat extends IterableBase<Vector3> {
  Iterator iterator;
  VerticesCollectionFromFlat(flatVertices) {
    iterator = new MeshVerticesIterator(flatVertices);
  }
}


/**
 * A Mesh belongs to a Model and holds geometrical and texturing information.
 *
 * Responsibilities:
 *   - generate the [vertices] to provide to the gl context during render.
 *   - generate the [uvs] to provide to the gl context during render of texture.
 *   - Optionally, generate a [boundingBox]. The default implementation should
 *     work with any list of vertices, but may not be optimal.
 *
 * You can implement this however you want.
 */
abstract class Mesh {

  int drawMode = WebGL.POINTS;

  /// API ----------------------------------------------------------------------

  /// A flat list of [vertices]'s coordinates. These should be draw-ready.
  List<double> get vertices;

  /// The number of above [vertices], depending on [drawMode].
  /// todo: there should be a default implementation working with WebGL.POINTS
  int get verticesCount;

  /// A flat list of [uvs] coordinates, to use with the TextureLayer.
  /// Each coordinate element is between 0 and 1, the origin being top left.
  /// If this is left null, the TextureLayer will raise an Error if used.
  List<double> get uvs => null;

  /// The [boundingBox] has a default getter implementation.
  /// It is not usually the optimal one for your special mesh,
  /// so override at will for better perfs.
  BoundingBox get boundingBox => _computeBoundingBox();


  BoundingBox _computeBoundingBox() {
    BoundingBox box = new BoundingBox();
    for (Vector3 vertex in verticesAsVector3) {
      box.expandToInclude(vertex);
    }
    return box;
  }

  Iterable<Vector3> get verticesAsVector3 => new VerticesCollectionFromFlat(vertices);

}


/**
 * A base mesh for GL_TRIANGLES meshes.
 */
abstract class TrianglesMesh extends Mesh {

  int drawMode = WebGL.TRIANGLES;

  int get verticesCount => (vertices.length / 3).toInt();

}


// todo: TrianglesStripMesh and TrianglesFanMesh. (default boundingBox will fail)
