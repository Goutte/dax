part of dax;


/**
 * Extend this with your own logic for world population.
 * Responsibilities :
 * - sets up a World for you to use
 * - fetches WebGL's RenderingContext with default parameters, unless you provide one.
 * - controls the rendering and updating flows
 * - provide input hooks :
 *   - mouse_moved
 *   - mouse_dragged
 *   - mouse_wheeled
 *
 * The (optional) Stats measure the cumulated rendering AND updating.
 */
abstract class Controller extends GameLoopHtml with EventEmitter {

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

    // Hook game_loop GameLoopHtml streams
    onRender = onDefaultRender;
    onUpdate = onDefaultUpdate;
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

  void onDefaultRender(GameLoopHtml self) {
    if (stats != null) { stats.begin(); }
    // We ask the renderer to draw the world
    renderer.draw(world);
    if (stats != null) { stats.end(); }
  }

  bool _isDragging = false;
  void onDefaultUpdate (GameLoopHtml self) {

//    print("update $time / $dt");
    world.update(time, dt);
    update(time, dt);

    num dx = mouse.dx;
    num dy = mouse.dy;

    if (dx != 0 || dy != 0) {
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



}