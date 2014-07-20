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
  Vector3 _right     = new Vector3(1.0, 0.0, 0.0);
  Vector3 _up        = new Vector3(0.0, 1.0, 0.0);
  Vector3 _direction = new Vector3(0.0, 0.0, -1.0);
  Quaternion _rotation  = new Quaternion.identity();

  Matrix4 _matrix = new Matrix4.identity();
  Matrix4 _inverseMatrix = new Matrix4.identity();
  Matrix3 _normalMatrix = new Matrix3.identity();
  Matrix3 _inverseNormalMatrix = new Matrix3.identity();

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

  Matrix3 get normalMatrix => _getNormalMatrix();
  Matrix3 get inverseNormalMatrix => _getInverseNormalMatrix();


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

  static const int SET_ROTATION_FLAGS =
      FLAG_INVERSE_MATRIX | FLAG_UP | FLAG_RIGHT | FLAG_DIRECTION |
      FLAG_NORMAL_MATRIX | FLAG_INVERSE_NORMAL_MATRIX;
  /**
   * Sets the rotation of this node to [newRotation], in world space.
   */
  void setRotation(Quaternion newRotation) {
    _rotation.copyFrom(newRotation);
    _matrix.setFromTranslationRotation(position, _rotation);
//    _stale ^= FLAG_MATRIX | FLAG_ROTATION;
    _stale |= SET_ROTATION_FLAGS;
  }


  static const int LOOK_AT_FLAGS =
      FLAG_MATRIX | FLAG_UP | FLAG_RIGHT | FLAG_DIRECTION | FLAG_ROTATION |
      FLAG_NORMAL_MATRIX | FLAG_INVERSE_NORMAL_MATRIX;
  /**
   * Analogous to the classic `gluLookAt`.
   * Repositions the camera at the world-space [eye] position,
   * orients the camera so that its local positive Y axis is
   * in the world-space direction of [up], and points the camera
   * towards the world-space position of [point].
   */
  void lookAt(Vector3 eye, Vector3 point, Vector3 up) {
    setViewMatrix(_inverseMatrix, eye, point, up);
    _position.setFrom(eye);
//    _stale ^= FLAG_INVERSE_MATRIX | FLAG_POSITION;
//    _stale ^= FLAG_POSITION;
    _stale |= FLAG_POSITION;
    _stale |= LOOK_AT_FLAGS;
    _doNotRecalculate(FLAG_INVERSE_MATRIX);
    _doNotRecalculate(FLAG_POSITION);
//    _stale ^= FLAG_INVERSE_MATRIX;
    // invalidate frustum, too
  }



  /// LOCAL SPACE //////////////////////////////////////////////////////////////

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

  /// REFERENTIAL CHANGE UTILS /////////////////////////////////////////////////

  /**
   * Transforms the given [localVector3] in local space to the same Vector3 in
   * world space. The result is placed in [out] and then returned.
   *
   * Example :
   *   node.toWorld3(out, new Vector3(0.0, 1.0, 0.0))
   *   => returns a Vector3 equal to node.up
   */
  Vector3 positionInWorld3(Vector3 out, Vector3 localVector3) {
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
  Vector3 positionInLocal3(Vector3 out, Vector3 worldVector3) {
    return inverseMatrix.transformed3(worldVector3, out);
  }

  Vector3 directionInWorld3(Vector3 out, Vector3 localVector3) {
    return normalMatrix.transformed(localVector3, out);
  }

  Vector3 directionInLocal3(Vector3 out, Vector3 worldVector3) {
    return inverseNormalMatrix.transformed(worldVector3, out);
  }


  /// PRIVVIES -----------------------------------------------------------------

  bool _doNotRecalculate(int attribute_flag) {
    if (_stale & attribute_flag > 0) {
      _stale ^= attribute_flag;
      return false;
    } else {
      return true;
    }
  }

  Vector3 _getPosition() {
    if (!_doNotRecalculate(FLAG_POSITION)) {
      positionInWorld3(_position, _origin);
    }
    return _position;
  }

  Vector3 _getUp() {
    if (!_doNotRecalculate(FLAG_UP)) {
      directionInWorld3(_up, unitY);
    }
    return _up;
  }

  Vector3 _getRight() {
    if (!_doNotRecalculate(FLAG_RIGHT)) {
      directionInWorld3(_right, unitX);
    }
    return _right;
  }

  Vector3 _getDirection() {
    if (!_doNotRecalculate(FLAG_DIRECTION)) {
//      print('recalc direction $_direction');
      directionInWorld3(_direction, unitZ * -1);
//      print('recalc direction $_direction');
    }
    return _direction;
  }

  Matrix4 _getMatrix() {
    if (!_doNotRecalculate(FLAG_MATRIX)) {
//      print('recalc matrix $_matrix');
      _matrix.copyInverse(inverseMatrix);
//      print('recalc matrix $_matrix');
    }
    return _matrix;
  }

  Matrix4 _getInverseMatrix() {
    if (!_doNotRecalculate(FLAG_INVERSE_MATRIX)) {
//      print('recalc inv matrix $_inverseMatrix');
      _inverseMatrix.copyInverse(matrix);
//      print('recalc inv matrix $_inverseMatrix');
    }
    return _inverseMatrix;
  }

  Matrix3 _getNormalMatrix() {
    if (!_doNotRecalculate(FLAG_NORMAL_MATRIX)) {
      _normalMatrix = _getNormalMatrixFromModelMatrix(matrix);
    }
    return _normalMatrix;
  }

  Matrix3 _getInverseNormalMatrix() {
    if (!_doNotRecalculate(FLAG_INVERSE_NORMAL_MATRIX)) {
      _inverseNormalMatrix= _getNormalMatrixFromModelMatrix(inverseMatrix);
    }
    return _inverseNormalMatrix;
  }

  /**
   * Ideally, move this to vector_math
   * Can also be de-vectorized to be faster, like
   * https://github.com/toji/gl-matrix/tree/master/src/gl-matrix/mat3.js
   * normal = transpose(inverse(model))
   */
  Matrix3 _getNormalMatrixFromModelMatrix(Matrix4 modelMatrix) {
    Matrix3 out = new Matrix3.identity();
    var a = modelMatrix;
    var a00 = a[0], a01 = a[1], a02 = a[2], a03 = a[3],
        a10 = a[4], a11 = a[5], a12 = a[6], a13 = a[7],
        a20 = a[8], a21 = a[9], a22 = a[10], a23 = a[11],
        a30 = a[12], a31 = a[13], a32 = a[14], a33 = a[15],

        b00 = a00 * a11 - a01 * a10,
        b01 = a00 * a12 - a02 * a10,
        b02 = a00 * a13 - a03 * a10,
        b03 = a01 * a12 - a02 * a11,
        b04 = a01 * a13 - a03 * a11,
        b05 = a02 * a13 - a03 * a12,
        b06 = a20 * a31 - a21 * a30,
        b07 = a20 * a32 - a22 * a30,
        b08 = a20 * a33 - a23 * a30,
        b09 = a21 * a32 - a22 * a31,
        b10 = a21 * a33 - a23 * a31,
        b11 = a22 * a33 - a23 * a32,

        // Calculate the determinant
        det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

    if (!det) { return out; }
    det = 1.0 / det;

    out[0] = (a11 * b11 - a12 * b10 + a13 * b09) * det;
    out[1] = (a12 * b08 - a10 * b11 - a13 * b07) * det;
    out[2] = (a10 * b10 - a11 * b08 + a13 * b06) * det;

    out[3] = (a02 * b10 - a01 * b11 - a03 * b09) * det;
    out[4] = (a00 * b11 - a02 * b08 + a03 * b07) * det;
    out[5] = (a01 * b08 - a00 * b10 - a03 * b06) * det;

    out[6] = (a31 * b05 - a32 * b04 + a33 * b03) * det;
    out[7] = (a32 * b02 - a30 * b05 - a33 * b01) * det;
    out[8] = (a30 * b04 - a31 * b02 + a33 * b00) * det;

    return out;
  }

}