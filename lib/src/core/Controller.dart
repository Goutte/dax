part of dax;


/**
 * Extend this with your own logic for world population.
 * Responsibilities :
 * - sets up a World for you to use
 * - fetches WebGL's RenderingContext with default parameters, unless you provide one.
 * - controls the rendering and updating flows
 *
 * The (optional) Stats measure the cumulated rendering AND updating.
 */
num _time = 0; // fixme: remove the need for this hack
abstract class Controller extends GameLoopHtml {

  WebGLRenderer renderer;
  World world;
  Stats stats;

  /// READ-ONLY (Jax would manage WRITING to these during runtime, not only on init)
  CanvasElement get canvas => this.element;
  WebGL.RenderingContext get gl => this._gl;
  /// Eventually, to replace the above gl.
  /// A Controller is a Human-Painter link/bridge
  //Painter get painter => this._gl;

  WebGL.RenderingContext _gl;
//  bool _isRendering = false;
//  bool _isUpdating = false;
//  num _time = 0;

  Controller(CanvasElement canvas, {
      Stats this.stats,
      WebGL.RenderingContext gl
  }) : super(canvas) {
    // Set up a world for the user to populate
    world = new World();
    // Get the WebGL RenderingContext from the CanvasElement
    if (gl == null) {
      gl = canvas.getContext3d(
          // we don't want alpha in the backbuffer, 99% of times
          alpha: false,
          // defaults
          depth: true, // if true, why do I also need DEPTH_TEST ?
          stencil: false,
          antialias: true,
          premultipliedAlpha: true,
          preserveDrawingBuffer: false
      );
    }
    this._gl = gl;
    // Set up the WebGL renderer
    renderer = new WebGLRenderer(this._gl);

    pointerLock.lockOnClick = false;

//    _time = time;

    onRender = onDefaultRender;
    onUpdate = onDefaultUpdate;



  }


  Vector3 _mouse_moved_camera_position = new Vector3(0.0,0.0,0.0);
  /// DEFAULTS : there should not be defaults here, but in mixins !
  /// this is only a draft
  mouse_moved(Mouse mouse) {

//    _mouse_moved_camera_position = world.camera.position;

    num strenght = 100;
//    _mouse_moved_camera_position.z = mouse.y.toDouble() / strenght;
//    _mouse_moved_camera_position.x = mouse.x.toDouble() / strenght;

//    print("New camera position: $_mouse_moved_camera_position");

//    world.camera.setPosition(_mouse_moved_camera_position);

  }



  Vector3 _mouse_wheeled_camera_position = new Vector3(0.0,0.0,0.0);
  /// DEFAULTS : there should not be defaults here, but in mixins !
  /// this is only a draft
  mouse_wheeled(Mouse mouse) {
    num minDistance = 3.0;
    num maxDistance = 42.0;

    print("position ${world.camera.position}");

    _mouse_wheeled_camera_position.setFrom(world.camera.position);

    num strenght = 1/400;
    _mouse_wheeled_camera_position.add(world.camera.direction * mouse.wheelDy * strenght);
    _mouse_wheeled_camera_position = constrainInCoconut(_mouse_wheeled_camera_position, new Vector3.zero(), minDistance, maxDistance);
    world.camera.setPosition(_mouse_wheeled_camera_position);
  }


  Vector3 _mouse_dragged_camera_position = new Vector3(0.0,0.0,0.0);
  /// DEFAULTS : there should not be defaults here, but in mixins !
  /// this is only a draft
  mouse_dragged(Mouse mouse) {

//    _mouse_moved_camera_position = world.camera.position;

    num strenght = 1/2500;

    Camera camera = world.camera;
    num dx = mouse.dx * strenght * -1;
    num dy = mouse.dy * strenght *  1;

//    print('dragged! $dx $dy');

    Quaternion _cameraQuatUp = new Quaternion.identity();
    Quaternion _cameraQuatRi = new Quaternion.identity();
    Quaternion _cameraQuat   = new Quaternion.identity();

    _cameraQuatUp.setAxisAngle(camera.up,    -1 * dx);
    _cameraQuatRi.setAxisAngle(camera.right, -1 * dy);
    _cameraQuat = _cameraQuatUp * _cameraQuatRi; // /!\ makes new quat


//    Vector3 oldDirection = camera.direction.clone();
//    camera.setDirection
    camera.setPosition(_cameraQuat.rotated(camera.position));



//    camera.setPosition vec3.transformQuat(_vecPosition, camera.get('position'), _cameraQuat)

//    print("New camera position: $_mouse_moved_camera_position");

//    world.camera.setPosition(_mouse_moved_camera_position);

  }



//  ###
//  Rotate with free yaw axis when mouse is in the inscribed circle of the canvas
//  Roll when out
//
//  You need, beforehand :
//      @context.activeCamera.setFixedYawAxis(false)
//
//  Numbers are in pixels (but this method kind of does not care)
//  X and Y along centered orthogonal referential, right and up positive
//  See `mouse_dragged` method for a conversion from event's x and y.
//
//  camera : the camera to rotate
//  x : the X position of the 2D cursor
//  y : the Y position of the 2D cursor
//  dx : difference from X of drag start
//  dy : difference from Y of drag start
//  w : width of the canvas
//  h : height of the canvas
//  ###
//  quat.setAxisAngle _cameraQuatUp, camera.get('up'),    -1 * dx
//  quat.setAxisAngle _cameraQuatRi, camera.get('right'), -1 * dy
//  quat.multiply _cameraQuat, _cameraQuatUp, _cameraQuatRi
//
//  oldDirection = vec3.clone camera.get('direction')
//  camera.setDirection vec3.transformQuat(_vecDirection, oldDirection, _cameraQuat), camera.get('up')

















  /**
   * Where would the [satellite] be in the [coconut] between the [min] sphere and the [max] sphere.
   * C'est pas la bulle qui grossit c'est le monde qui se rapproche.
   */
  Vector3 constrainInCoconut(Vector3 satellite, Vector3 coconut, num min, num max) {
    Vector3 diff = satellite - coconut;
    if (diff.length2 < min * min) {
      diff.normalize().scale(min);
    } else if (diff.length2 > max * max) {
      diff.normalize().scale(max);
    }
    return coconut + diff;
  }

  void onDefaultRender(GameLoopHtml self) {
    if (stats != null) { stats.begin(); }
    // We ask the renderer to draw the world
    renderer.draw(world);
    if (stats != null) { stats.end(); }
  }

  bool _isDragging = false;
  void onDefaultUpdate (GameLoopHtml self) {
//    num delta = time - _time;
//    print("update $time / $dt");
    world.update(time, dt);
    update(time, dt);

    num dx = mouse.dx;
    num dy = mouse.dy;

    if (dx != 0 && dy != 0) {
      if (mouse.isDown(0)) {
        mouse_dragged(mouse);
      }
      else {
        mouse_moved(mouse);
      }
    }

    // WHEEL
    if (mouse.wheelDx != 0 || mouse.wheelDy != 0) {
      mouse_wheeled(mouse);
    }
  }

//  void update(num time, num dt) {
//    world.update(time, dt);
//  }

  void update(num time, num delta){}

}