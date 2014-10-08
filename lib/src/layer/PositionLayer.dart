part of dax;


/**
 * This material layer takes care of `gl_Position`, and sets VERTEX_POSITION
 * to be shared amongst all future layers of the material.
 * It should be part of all materials, as no other shader will take care of
 * gl_Position, unless you roll your own that does.
 *
 * VERTEX_POSITION holds the raw coordinates of the vertices of the mesh,
 * so they're only influenced by the mesh constructor. (`size` option, etc.)
 *
 * The matrices will also be shared eventually.
 */
class PositionLayer extends MaterialLayer {

  String get glslVertex => """
shared attribute vec3 VERTEX_POSITION;

uniform mat4 uMMatrix;
uniform mat4 uVMatrix;
uniform mat4 uPMatrix;

shared varying vec3 FRAGMENT_LOCAL_POSITION;

void main(void) {
    FRAGMENT_LOCAL_POSITION = VERTEX_POSITION;
    gl_Position = uPMatrix * uVMatrix * uMMatrix * vec4(VERTEX_POSITION, 1.0);
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
        // todo: compute only if the camera moved
        'uPMatrix': world.camera.perspectiveMatrix,
        'uVMatrix': world.camera.viewMatrix,
    };
  }

}