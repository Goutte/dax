part of dax;


/**
 * Intended as an Interface for a SceneNode.
 * The Renderer will check if the node is Renderable while traversing the
 * SceneGraph, and if it is, it will paint the [mesh] with the [material].
 */
abstract class Renderable implements Positionable, Shadable {}


/**
 * Intended as an Interface for a SceneNode.
 * If a SceneNode is Positionable but not Shadable, the Renderer skips it.
 */
abstract class Positionable {
  Mesh get mesh;
}


/**
 * Intended as an Interface for a SceneNode.
 * If a SceneNode is Shadable but not Positionable, nothing happens atm.
 * Ideally, the material should be rendered on the whole screen, but when ?
 * Before the models ? After ? Bewteen ? Should be able to choose. How ?
 */
abstract class Shadable {
  Material get material;
}


/**
 * Intended as an Interface for a SceneNode.
 * The world will update its Updatable scene nodes.
 */
abstract class Updatable {
  /**
   * It provided the [time] since the beginning and the [delta] since the last
   * update, both in seconds. (they should be, they might not be -- wip).
   */
  void update(num time, num delta);
}