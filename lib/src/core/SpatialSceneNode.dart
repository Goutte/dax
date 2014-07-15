part of dax;

/**  FROM JAX
The following **read-only** attributes should also be available:

    - `mat4 inverseConcatenatedMatrices`
    - `mat3 normalMatrix`
    - `mat3 inverseNormalMatrix`
    - `quat rotation`
*/

/**
 * A SpatialSceneNode is a SceneNode that is spatially positioned.
 *
 * It has many attributes available, but you should NEVER try to assign values
 * to these attributes. You should only use the methods exposed to interact
 * with the attributes, as they make sure to keep the co-dependent attributes
 * up to date.
 *
 * Note: There's a LOT more to do here, this is far from complete!
 */
class SpatialSceneNode extends SceneNode {

  Vector3 _position  = new Vector3(0.0, 0.0, 0.0);
  Vector3 _right     = new Vector3(0.0, 1.0, 0.0);
  Vector3 _up        = new Vector3(0.0, 1.0, 0.0);
  Vector3 _direction = new Vector3(0.0, 0.0, -1.0);

  Matrix4 _matrix = new Matrix4.identity();
  Matrix4 _inverseMatrix = new Matrix4.identity();

  /// Unitary vectors for convenience -- PROTECTED attributes, not really public
  Vector3 unitX = new Vector3(1.0, 0.0, 0.0);
  Vector3 unitY = new Vector3(0.0, 1.0, 0.0);
  Vector3 unitZ = new Vector3(0.0, 0.0, 1.0);
  /// Position of origin
  Vector3 _origin = new Vector3(0.0, 0.0, 0.0);

  /// Attributes flags to mark stale data so we don't recalculate unnecessarily
  int _stale = 0x000;
  static const int FLAG_MATRIX                = 0x001;
  static const int FLAG_INVERSE_MATRIX        = 0x002;
  static const int FLAG_POSITION              = 0x004;
  static const int FLAG_UP                    = 0x008;
  static const int FLAG_RIGHT                 = 0x010;
  static const int FLAG_DIRECTION             = 0x020;
  static const int FLAG_ROTATION              = 0x040;
  static const int FLAG_NORMAL_MATRIX         = 0x080;
  static const int FLAG_INVERSE_NORMAL_MATRIX = 0x100;


  /// GETTERS ------------------------------------------------------------------

  /// The spatial and cartesian (x,y,z) [position] of this node.
  Vector3 get position => _getPosition();
  /// A (normalized) cartesian vector in world space, looking [right].
  Vector3 get right => _getRight();
  /// A (normalized) cartesian vector in world space, looking [forward].
  /// It is also the [direction] of the node.
  Vector3 get direction => _getDirection();
  Vector3 get forward   => _getDirection();
  /// A (normalized) cartesian vector in world space, looking [up].
  Vector3 get up => _getUp();
  /// The matrix of referential change from local to world space.
  Matrix4 get matrix => _getMatrix();
  /// The matrix of referential change from world to local space.
  Matrix4 get inverseMatrix => _getInverseMatrix();


  /// CONSTRUCTORS -------------------------------------------------------------

  SpatialSceneNode() : super() {}

  /// API ----------------------------------------------------------------------

  static const int SET_POSITION_FLAGS =
      FLAG_POSITION | FLAG_INVERSE_MATRIX |
      FLAG_NORMAL_MATRIX | FLAG_INVERSE_NORMAL_MATRIX;
  /**
   * Sets the position of this node to [newPosition], in world space.
   */
  void setPosition(Vector3 newPosition) {
    _matrix = matrix;
    _matrix.setTranslation(newPosition);
    _stale |= SET_POSITION_FLAGS;
  }

  static const int ROTATE_FLAGS =
      FLAG_UP | FLAG_RIGHT | FLAG_DIRECTION | FLAG_ROTATION |
      FLAG_INVERSE_MATRIX | FLAG_NORMAL_MATRIX | FLAG_INVERSE_NORMAL_MATRIX;
  /**
   * Rotates this node by [amountInRadians], [alongAxis] in local space.
   * It makes no difference whether [alongAxis] is normalized or not.
   */
  void rotate(num amountInRadians, Vector3 alongAxis) {
    _matrix = matrix.rotate(alongAxis, amountInRadians);
    _stale |= ROTATE_FLAGS;
  }

  /**
   * Transforms the given [localVector3] in local space to the same Vector3 in
   * world space. The result is placed in [out] and then returned.
   *
   * Example :
   *   node.toWorld3(out, new Vector3(0.0, 1.0, 0.0))
   *   => returns a Vector3 equal to node.up
   */
  Vector3 toWorld3(Vector3 out, Vector3 localVector3) {
    return matrix.transformed3(localVector3, out);
  }

  /**
   * Transforms the given [worldVector3] in world space to the same Vector3 in
   * local space. The result is placed in [out] and then returned.
   *
   * Example :
   *   node.toLocal3(out, node.up)
   *   => returns a Vector3 equal to (0.0, 1.0, 0.0)
   */
  Vector3 toLocal3(Vector3 out, Vector3 worldVector3) {
    return inverseMatrix.transformed3(worldVector3, out);
  }


  /// PRIVVIES -----------------------------------------------------------------

  bool _shouldRecalculate(int attribute_flag) {
    if (_stale & attribute_flag > 0) {
      _stale ^= attribute_flag;
      return true;
    } else {
      return false;
    }
  }

  Vector3 _getPosition() {
    if (_shouldRecalculate(FLAG_POSITION)) {
      toWorld3(_position, _origin);
    }
    return _position;
  }

  Vector3 _getUp() {
    if (_shouldRecalculate(FLAG_UP)) {
      toWorld3(_up, unitY);
    }
    return _up;
  }

  Vector3 _getRight() {
    if (_shouldRecalculate(FLAG_RIGHT)) {
      toWorld3(_right, unitX);
    }
    return _right;
  }

  Vector3 _getDirection() {
    if (_shouldRecalculate(FLAG_DIRECTION)) {
      toWorld3(_direction, unitZ * -1);
    }
    return _direction;
  }

  Matrix4 _getMatrix() {
    if (_shouldRecalculate(FLAG_MATRIX)) {
      _matrix.copyInverse(inverseMatrix);
    }
    return _matrix;
  }

  Matrix4 _getInverseMatrix() {
    if (_shouldRecalculate(FLAG_INVERSE_MATRIX)) {
      _inverseMatrix.copyInverse(matrix);
    }
    return _inverseMatrix;
  }

}