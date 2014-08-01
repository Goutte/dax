part of dax;

/**
 * A shader that does not shade anything, but fills VERTEX_MIN and VERTEX_MAX.
 * They hold respectively the min and max on each axis of VERTEX_POSITION.
 */
class BoundariesLayer extends MaterialLayer {

  /// VERTEX SHADER ------------------------------------------------------------

  String get glslVertex => """
shared uniform vec3 VERTEX_MIN;
shared uniform vec3 VERTEX_MAX;

void main(void) {}
  """;

  /// FRAGMENT SHADER ----------------------------------------------------------

  String get glslFragment => "";

  BoundariesLayer() : super();

  Map<String, dynamic> onSetup(World world, Model model, Renderer renderer) {
    return onDraw(world, model, renderer);
  }

  Vector3 _vertexMin = new Vector3.zero();
  Vector3 _vertexMax = new Vector3.zero();
  Map<String, dynamic> onDraw(World world, Model model, Renderer renderer) {
    BoundingBox box = model.mesh.boundingBox; // /!\ not memoized yet -- todo
    _vertexMin.setValues(box.xMin, box.yMin, box.zMin);
    _vertexMax.setValues(box.xMax, box.yMax, box.zMax);
    return {
        'VERTEX_MIN': _vertexMin,
        'VERTEX_MAX': _vertexMax,
    };
  }

}