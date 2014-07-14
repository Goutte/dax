part of dax;


/**
 * Models encapsulate virtually all business logic.
 * If a Monster knows how to attack, the logic that makes it do so is held
 * within the +Monster+ model.
 * If the terrain has trees and other vegetation,
 * the +Terrain+ model is responsible for setting that up.
 *
 * While controllers generally have only high-level code
 * such as initial scene set-up and processing of user input,
 * models handle nearly everything else.
 */
class Model extends SpatialSceneNode implements Renderable, Shadable {}