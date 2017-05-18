part of dax;


Quaternion _cameraQuatUp = new Quaternion.identity();
Quaternion _cameraQuatRi = new Quaternion.identity();
Quaternion _cameraQuat   = new Quaternion.identity();
Vector3 _cameraDirection = new Vector3.zero();
Vector3 _cameraPosition  = new Vector3.zero();

/**
 * Responsibilities:
 *   - provides an API to move in a sphere around a focus point.
 *   - C'est pas la bulle qui grossit c'est le monde qui se rapproche. (didi)
 *
 * Caveats:
 *   - (tofix) If the focus is not (0,0,0), the camera will misbehave.
 */
class TrackballCamera extends Camera implements Updatable {

  /// Cartesian velocities. On each update, their values will be used to create
  /// a quaternion rotation. Their referential is the right-handed eye of the
  /// observer : X to the right, Y to the top, and Z poking in the eye.
  /// In this case, the right-handed convention (from maths and physics, afaik)
  /// is a debatable choice, as Z going towards the focal point feels intuitive
  /// as well. Please voice which one you prefer and think is best.
  num dx = 0.0;
  num dy = 0.0;
  num dz = 0.0;

  /// OPTIONS

  /**
   * Fraction of energy that will be lost on each update.
   * Must be between 0 and 1, inclusive.
   * If this value is set to 1, the camera won't move. Don't do that.
   * If this value is set to something greater than 1,
   * the movement will exponentially(?) accelerate
   * until something spins out of control, breaks and burns. (usually, a brain)
   * You can change this value at any time.
   */
  num friction = 1/11;

  /**
   * When, through repeated friction, the speed becomes less that this value,
   * it will be clamped to zero (0). This value should be set as the minimum
   * momentum needed to make the canvas pixels actually change.
   */
  num mimimum = 2e-3;

  num closest = 1.0;
  num farthest = 7.0;

  /// CONSTRUCTORS -------------------------------------------------------------

//  TrackballCamera();

  /// API ----------------------------------------------------------------------

  /**
   * Move that camera in the trackball space with the forces [dx], [dy] and [dz]
   * along their respective axes.
   * In the regular right-handed 3D referential, X to the right, Y to the top,
   * and Z to the eye. Meaning that a positive [dz] value will make the camera
   * back up from its focus.
   * A positive [dx] value will move the camera to the right and it will look as
   * if the object of its focus is rotating from East to West.
   * A positive [dy] value will move the camera to the top and it will look as
   * if the object of its focus is rotating from North to South.
   *
   * The camera is constrained within the [closest] and the [farthest]
   * distance of its focus point, with a smooth tolerance.
   */
  void trackball(num dx, num dy, num dz) {
    this.dx += dx;
    this.dy += dy;
    this.dz += dz;
  }

  /// OVERRIDES ----------------------------------------------------------------

  /**
   * Will move the camera in trackball space according to its momentum.
   */
  void update(num time, num delta) {
    // Apply friction to reduce the speed
    // (multiply it every tick by something slightly less than 1)
    if (friction != 0.0) {
      num friction_coeff = (1.0 - friction);
      dx = dx * friction_coeff;
      dy = dy * friction_coeff;
      dz = dz * friction_coeff;
    }

    if (dx.abs() < mimimum) { dx = 0.0; }
    if (dy.abs() < mimimum) { dy = 0.0; }
    if (dz.abs() < mimimum/10.0) { dz = 0.0; }

    // Rotate around focus
    if (dx != 0.0 || dy != 0.0) {
      _cameraQuatUp.setAxisAngle(up,    -1.0 * dx);
      _cameraQuatRi.setAxisAngle(right,  1.0 * dy);
      _cameraQuat = _cameraQuatUp.multiplyInto(_cameraQuatRi, _cameraQuat);

      Vector3 oldDirection = direction.clone();
      _cameraDirection = _cameraQuat.rotated(oldDirection);
      setDirection(_cameraDirection, up);

      setPosition(_cameraQuat.rotated(position));
    }

    // should be the length of (position - focus)
    num distance = position.length;

    // Move along direction axis
    if (dz != 0.0) {
      _cameraPosition.setFrom(position);
      // We're too close ! Too close to the WIRE !
      if (dz < 0 && distance < closest) { dz = dz * 0.333; }
      // We're too faaaaaar awaaaaaaa-a-aa-aaay !
      if (dz > 0 && distance > farthest) { dz = dz * 0.999; }
      _cameraPosition.add(direction * dz * -1.0);
      setPosition(_cameraPosition);
    }

    // Smooth push towards boundaries if out of them
    if (distance < closest) {
      dz = dz + (closest - distance) * 0.111;
    }
    if (distance > farthest) {
      dz = dz - (distance - farthest) * 0.00333;
    }
  }

}