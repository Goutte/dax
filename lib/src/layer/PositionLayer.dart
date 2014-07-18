part of dax;


/**
 * This material layer takes care of `gl_Position`.
 * It should be part of all materials.
 */
class PositionLayer extends MaterialLayer {

  String get glslFragment => "";
  String get glslVertex => """
attribute vec3 VERTEX_POSITION;

uniform mat4 uMMatrix;
uniform mat4 uVMatrix;
uniform mat4 uPMatrix;

void main(void) {
    gl_Position = uPMatrix * uVMatrix * uMMatrix * vec4(VERTEX_POSITION, 1.0);
}
  """;


  Map<String, dynamic> onSetup(World world, Model model, Renderer renderer) {
    return {
        'uPMatrix': world.camera.perspectiveMatrix,
        'uVMatrix': world.camera.viewMatrix,
    };
  }

  Map<String, dynamic> onDraw(World world, Model model, Renderer renderer) {
    // fixme: VERTEX_POSITION as shared attribute
    return {
        'VERTEX_POSITION': model.mesh.vertices,
        'uMMatrix': model.matrix,
        // todo: compute only if the camera moved
        'uPMatrix': world.camera.perspectiveMatrix,
        'uVMatrix': world.camera.viewMatrix,
    };
  }

}