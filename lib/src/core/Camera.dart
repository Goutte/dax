part of dax;

/**
 * When Referentials are implemented, the Camera's attributes should account for
 * the Referential of the [parent] SceneNode.
 *
 * By default, a Camera mimics the eye of an user looking at a screen,
 * by setting a negative position along Z and focusing the origin, with Y up.
 *
 * Y
 * + X
 * (Z is towards you, as per right-hand convention)
 */
class Camera extends SpatialSceneNode {

  /// Memoization holders

  Matrix4 _pMatrix;
  Matrix4 _vMatrix;
  bool _pMatrixStale = false;
  bool _vMatrixStale = false;

  /// Options

  int width = 1;
  int height = 1;

  num fov  = 0.765398; // 45° in radians
  num near = 0.1;
  num far  = 100;

  /// GETTERS ------------------------------------------------------------------

  /// The spatial and cartesian (x,y,z) position of the [focus] of the camera.
  Vector3 get focus => position + direction;

  num get aspect => width / height;

  Matrix4 get perspectiveMatrix => _getPerspectiveMatrix();
  Matrix4 get viewMatrix => _getViewMatrix();

  /// CONSTRUCTORS -------------------------------------------------------------

  Camera({ Vector3 position, Vector3 focus, Vector3 up }) : super() {
    if (position == null) position = new Vector3(0.0, 0.0, 10.0);
    if (focus == null) focus = new Vector3(0.0, 0.0, 0.0);
    if (up == null) up = new Vector3(0.0, 1.0, 0.0);

    lookAt(position, focus, up);

    _pMatrix = makePerspectiveMatrix(fov, aspect, near, far);
    _vMatrix = makeViewMatrix(position, focus, up);
  }

  /// OVERRIDES ----------------------------------------------------------------

  /// API ----------------------------------------------------------------------

  /// PRIVVIES -----------------------------------------------------------------

  Matrix4 _getPerspectiveMatrix() {
    if (_pMatrixStale || true) {
      setPerspectiveMatrix(_pMatrix, fov, aspect, near, far);
      _pMatrixStale = false;
    }
    return _pMatrix;
  }

  Matrix4 _getViewMatrix() {
    if (_vMatrixStale || true) {
      setViewMatrix(_vMatrix, position, focus, up);
      _vMatrixStale = false;
    }
    return _vMatrix;
  }

}