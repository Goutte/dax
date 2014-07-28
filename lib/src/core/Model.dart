part of dax;


/**
 * Models encapsulate virtually all business logic.
 *
 * If a Monster knows how to attack, the logic that makes it do so is held
 * within the +Monster+ model.
 * If the terrain has trees and other vegetation,
 * the +Terrain+ model is responsible for setting that up.
 *
 * While controllers generally have only high-level code
 * such as initial scene set-up and processing of user input,
 * models handle nearly everything else.
 *
 * A Model automatically has the default material DefaultMaterial.
 */
abstract class Model extends SpatialSceneNode implements Positionable, Shadable, Updatable {

  Material _material = new DefaultMaterial();
  Material get material => _material;

  /// To override with your own logic.
  /// The [time] since the first render is available, as well as
  /// the [deltaTime] since the last render.
  /// They're both in milliseconds (i think). They should be in seconds.
  void update(num time, num delta){}

}