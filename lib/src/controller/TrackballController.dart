part of dax;


/**
 * Mixins do not work with optional parameters in the constructor, because
 * `forwarding constructors must not have optional parameters`.
 * Even when the mixin itself has no constructor defined. Hmmm.
 *
 * Therefore, here is a handy Controller to extend that will bind the mouse
 * inputs to the trackball camera.
 *
 * You can override [drag_strength] and [wheel_strength].
 */
class TrackballController extends Controller {

  TrackballCamera get camera => world.camera;

  TrackballController(CanvasElement canvas, {Stats stats}) :
  super(canvas, stats: stats, camera: new TrackballCamera());

  num drag_strength = 1/777;
  mouse_dragged(Mouse mouse) {
    TrackballCamera camera = world.camera;
    num dx = mouse.dx * drag_strength * -1;
    num dy = mouse.dy * drag_strength; // oddity, see game_loop
    camera.trackball(dx, dy, 0.0);
  }

  num wheel_strength = 1/5555;
  mouse_wheeled(Mouse mouse) {
    TrackballCamera camera = world.camera;
    num dz = mouse.wheelDy.toDouble() * wheel_strength;
    camera.trackball(0.0, 0.0, dz);
  }


  num touch_drag_strength = 1/999;
  touch_dragged(GameLoopTouch touch) {
    if (touch.positions.length < 2) { return; }
    TrackballCamera camera = world.camera;
    GameLoopTouchPosition p1 = touch.positions[touch.positions.length-2];
    GameLoopTouchPosition p2 = touch.positions[touch.positions.length-1];
    num dx = (p2.x-p1.x) * touch_drag_strength * -1;
    num dy = (p2.y-p1.y) * touch_drag_strength; // oddity, see game_loop
    camera.trackball(dx, dy, 0.0);
  }
}
