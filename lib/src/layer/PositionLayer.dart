part of dax;


/**
 * This material layer takes care of `gl_Position`, and sets some variables
 * to be shared amongst all future layers of the material.
 * It should be part of all materials, as no other shader layer will take care
 * of gl_Position, unless you roll your own that does.
 *
 * VERTEX_POSITION holds the raw/local coordinates of the vertices of the mesh,
 * so they're only influenced by the mesh constructor. (`size` option, etc.)
 *
 * FRAGMENT_LOCAL_POSITION is a varying for to the fragment shader, and holds
 * the position of the fragment in its local mesh.
 *
 * FRAGMENT_WORLD_POSITION is a varying for to the fragment shader, and hold the
 * position of the fragment after its model matrix multiplication, so it's in
 * world space.
 *
 * The matrices will also probably be shared eventually.
 */
class PositionLayer extends MaterialLayer {

  String get glslVertex => """
shared attribute vec3 VERTEX_POSITION;

uniform mat4 uMMatrix;
uniform mat4 uVMatrix;
uniform mat4 uPMatrix;

// Holds the fragment position in the local mesh
shared varying vec3 FRAGMENT_LOCAL_POSITION;
// Holds the fragment position in the world
shared varying vec3 FRAGMENT_WORLD_POSITION;


void main(void) {
    vec4 worldPosition = uMMatrix * vec4(VERTEX_POSITION, 1.0);
    FRAGMENT_LOCAL_POSITION = VERTEX_POSITION;
    FRAGMENT_WORLD_POSITION = vec3(worldPosition);
    gl_Position = uPMatrix * uVMatrix * worldPosition;
}
  """;
  String get glslFragment => """
shared varying vec3 FRAGMENT_LOCAL_POSITION;
  """;


  Map<String, dynamic> onSetup(World world, Model model, Renderer renderer) {
    return {
        'uPMatrix': world.camera.perspectiveMatrix,
        'uVMatrix': world.camera.viewMatrix,
    };
  }

  Map<String, dynamic> onDraw(World world, Model model, Renderer renderer) {
    return {
        'VERTEX_POSITION': model.mesh.vertices,
        'uMMatrix': model.matrix,
        // todo: precompute in Dart the multiplication, only if the camera moved
        'uPMatrix': world.camera.perspectiveMatrix,
        'uVMatrix': world.camera.viewMatrix,
    };
  }

}