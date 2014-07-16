part of dax;


/**
 * Extend this with your own logic for world population.
 * Responsibilities :
 * - sets up a World for you to use
 * - fetches WebGL's RenderingContext with default parameters
 * - controls the rendering and updating flows
 *
 * The (optional) Stats measure the cumulated rendering AND updating.
 */
abstract class Controller {

  CanvasElement canvas;
  WebGL.RenderingContext gl;
  WebGLRenderer renderer;
  World world;
  Stats stats;

  bool _isRendering = false;
  bool _isUpdating = false;
  num _time = 0;


  Controller(CanvasElement this.canvas, {Stats this.stats}) {
    // Get the WebGL RenderingContext from the CanvasElement
    gl = canvas.getContext3d(
        // we don't want alpha in the backbuffer, 99% of times
        alpha: false,
        // defaults
        depth: true,
        stencil: false,
        antialias: true,
        premultipliedAlpha: true,
        preserveDrawingBuffer: false
    );
    // Set up the WebGL renderer
    renderer = new WebGLRenderer(gl);
    // Set up a world for the user to populate
    world = new World();
  }


  void startRendering() {
    if (_isRendering) return;
    _isRendering = true;
    render(_time);
  }

  void stopRendering() {
    if (!_isRendering) return;
    _isRendering = false;
  }

  void startUpdating() {
    if (_isUpdating) return;
    _isUpdating = true;
  }

  void stopUpdating() {
    if (!_isUpdating) return;
    _isUpdating = false;
  }

  void render(num time) {
    if (_isRendering || _isUpdating) {
      window.animationFrame.then(render);
    }
    if (stats != null) { stats.begin(); }
    if (_isRendering) {
      // We ask the renderer to draw the world
      renderer.draw(world);
    }
    if (_isUpdating) {
      update(time, time - _time);
    }
    if (stats != null) { stats.end(); }

    _time = time;
  }

  void update(num time, num dt) {
    world.update(time, dt);
  }

}