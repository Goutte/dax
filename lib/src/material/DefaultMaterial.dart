part of dax;


/**
 * The material used by default when not provided by the model.
 */
class DefaultMaterial extends Material {

  DefaultMaterial() : super() {
    layers.add(new PositionLayer());
    layers.add(new ColorLayer());
  }

}

