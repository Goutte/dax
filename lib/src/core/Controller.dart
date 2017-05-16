part of dax;


/**
 * Extend this with your own logic for world population.
 * Responsibilities :
 * - sets up a World for you to use
 * - fetches WebGL's RenderingContext with default parameters, unless you provide one.
 * - controls the rendering and updating flows
 * - provide input hooks :
 *   - mouse_clicked
 *   - mouse_moved
 *   - mouse_dragged
 *   - mouse_wheeled
 *   - (copied jax's `_` syntax. Not sure if best, though.)
 *     Options:
 *        - mouse_clicked override (jax)
 *        - mouseClicked override (dart ?)
 *        - onMouseClick <= no, this should be a listenable Stream ?
 *
 * The (optional) Stats measure the cumulated rendering AND updating.
 *
 * I really am not satisfied with the current input hooking.
 * It would probably best to roll our own, or improve game_loop if it evolves for the better.
 */
abstract class Controller extends GameLoopHtml /*with EventEmitter*/ {

  WebGLRenderer renderer;
  World world;
  Stats stats;

  /// READ-ONLY (Jax would manage WRITING to these during runtime, not only on init)
  CanvasElement get canvas => this.element; // from GameLoopHtml
  WebGL.RenderingContext get gl => this._gl;
  /// Eventually, to replace the above gl, to support CSS3 or SVG.
  /// A Controller is a Human-Painter link/bridge, via Inputs
  /// But that's a lot of work, and it means wrapping WebGL.RenderingContext too
  /// Not sure what would be the difference between Renderer and Painter
  //Painter get painter => this._painter;

  WebGL.RenderingContext _gl;
//  bool _isRendering = false;
//  bool _isUpdating = false;

  Controller(CanvasElement canvas, {
      Stats this.stats,
      WebGL.RenderingContext gl,
      Camera camera
  }) : super(canvas) {

    // Set up a world for the user to populate
    world = new World(camera: camera);

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

    // Make sure that the pointer lock on click is disabled
    pointerLock.lockOnClick = false;

    // Hook game_loop's GameLoopHtml streams
    onRender = onDefaultRender;
    onUpdate = onDefaultUpdate;

    // Desactivate the mouse drag when mouse leaves the canvas
    // This is an ugly hack -- this belongs in the game loop.
    canvas.onMouseLeave.listen((Event e) {
      mouse.buttons[Mouse.LEFT].timeReleased = mouse.buttons[Mouse.LEFT].timePressed;
      mouse.buttons[Mouse.LEFT].frameReleased = mouse.buttons[Mouse.LEFT].framePressed;
    });
  }


  /// API ----------------------------------------------------------------------

  /**
   * Override this.
   * It is called on each update, with the [time] since the beginning and the
   * [delta] since last update, both in seconds. (eventually, they may well not yet be)
   */
  update(num time, num delta) {}

  /**
   * Override this.
   * It is called on each [mouse] click of [buttonId].
   * [buttonId] can be Mouse.LEFT, Mouse.RIGHT or MOUSE.MIDDLE.
   */
  mouse_clicked(Mouse mouse, int buttonId) {}

  /**
   * Override this.
   * It is called on each move of the [mouse].
   */
  mouse_moved(Mouse mouse) {}

  /**
   * Override this.
   * It is called on each vertical [mouse] wheel.
   */
  mouse_wheeled(Mouse mouse) {}


  /**
   * Override this.
   * It is called on each drag of the [mouse].
   */
  mouse_dragged(Mouse mouse) {}










  /// HOOKS FOR GAME_LOOP ------------------------------------------------------

  // This lot may well go away when we either fork game_loop and patch it, or roll our own.
  // I really am not satified by this.

  void onDefaultRender(GameLoopHtml self) {
    if (stats != null) { stats.begin(); }
    // We ask the renderer to draw the world
    renderer.draw(world);
    if (stats != null) { stats.end(); }
  }

  num _mouseClickTolerance = 0.00001;
  bool _isDragging = false;
  bool _isClicking = false;
  num _dxSinceDown = 0.0;
  num _dySinceDown = 0.0;
  void onDefaultUpdate (GameLoopHtml self) {

//    print("update $time / $dt");
    world.update(time, dt);
    update(time, dt);

    num dx = mouse.dx;
    num dy = mouse.dy;

    // LEFT CLICK
    if (mouse.pressed(Mouse.LEFT)) {
      _isClicking = true;
      _dxSinceDown = 0.0;
      _dySinceDown = 0.0;
    }
    if (mouse.isDown(Mouse.LEFT)) {
      _dxSinceDown += dx.abs();
      _dySinceDown += dy.abs();
    }
    if (mouse.released(Mouse.LEFT)) {
      _isClicking = true;

      if (_dxSinceDown < _mouseClickTolerance ||
          _dySinceDown < _mouseClickTolerance) {
        mouse_clicked(mouse, Mouse.LEFT);
      }
    }

    // MOVE AND DRAG
    if (mouse.dx != 0 || mouse.dy != 0) {
      if (mouse.isDown(Mouse.LEFT)) {
        mouse_dragged(mouse);
      }
      else {
        mouse_moved(mouse);
      }
    }

    // VERTICAL WHEEL
    if (mouse.wheelDy != 0) {
      mouse_wheeled(mouse);
    }
  }



}