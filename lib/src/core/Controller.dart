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
  mouse_moved(Mouse mouse) {

    /// DEFAULTS : there should not be defaults here, but in mixins !
    /// this is only a draft
    _mouse_moved_camera_position = world.camera.position;

    num strenght = 100;
    _mouse_moved_camera_position.z = mouse.y.toDouble() / strenght;
    _mouse_moved_camera_position.x = mouse.x.toDouble() / strenght;

//    print("New camera position: $_mouse_moved_camera_position");

    world.camera.setPosition(_mouse_moved_camera_position);

  }


  Vector3 _mouse_wheeled_camera_position = new Vector3(0.0,0.0,0.0);
  mouse_wheeled(Mouse mouse) {

    /// DEFAULTS : there should not be defaults here, but in mixins !
    /// this is only a draft
    _mouse_wheeled_camera_position.setFrom(world.camera.position);

    num strenght = -1/100;
    _mouse_wheeled_camera_position.add(world.camera.direction * mouse.wheelDy * strenght);
//    _mouse_wheeled_camera_position.x = mouse.x.toDouble() / strenght;

//    print("New camera position: $_mouse_moved_camera_position");

    world.camera.setPosition(_mouse_wheeled_camera_position);

  }

//  void _requestAnimationFrame(num _) {
//    super._requestAnimationFrame(_);
//  }

//  setRenderingContext() {
//
//  }

//  void startListening() {
//    if (_initialized == false) {
//      document.onFullscreenError.listen(_fullscreenError);
//      document.onFullscreenChange.listen(_fullscreenChange);
//      element.onTouchStart.listen(_touchStartEvent);
//      element.onTouchEnd.listen(_touchEndEvent);
//      element.onTouchCancel.listen(_touchEndEvent);
//      element.onTouchMove.listen(_touchMoveEvent);
//      window.onKeyDown.listen(_keyDown);
//      window.onKeyUp.listen(_keyUp);
//      window.onResize.listen(_resize);
//
//      element.onMouseMove.listen(_mouseMove);
//      element.onMouseDown.listen(_mouseDown);
//      element.onMouseUp.listen(_mouseUp);
//      element.onMouseWheel.listen(_mouseWheel);
//      _initialized = true;
//    }
//    _interrupt = false;
//  }

//  void startRendering() {
//    if (_isRendering) return;
//    _isRendering = true;
//    render(_time);
//  }
//
//  void stopRendering() {
//    if (!_isRendering) return;
//    _isRendering = false;
//  }

//  void startUpdating() {
//    if (_isUpdating) return;
//    _isUpdating = true;
//  }
//
//  void stopUpdating() {
//    if (!_isUpdating) return;
//    _isUpdating = false;
//  }

  void onDefaultRender(GameLoopHtml self) {
    if (stats != null) { stats.begin(); }
    // We ask the renderer to draw the world
    renderer.draw(world);
//    if (_isUpdating) {
      //update(time, time - _time);
//    }
    if (stats != null) { stats.end(); }

  }

  void onDefaultUpdate (GameLoopHtml self) {
//    num delta = time - _time;
//    print("update $time / $dt");
    world.update(time, dt);
//    update(time, dt);

    num dx = mouse.dx;
    num dy = mouse.dy;

    if (dx != 0 && dy != 0) {
//      print("mouse_moved($dx / ${mouse.x}, $dy / ${mouse.y})");
      mouse_moved(mouse);
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