part of dax;


/**
 * A scene node is something to be added to the scene graph.
 * It may be Positionable, Renderable, Shadable.
 * Without any of these traits, a scene node is basically a convenience group
 * for sorting and recursive removal.
 *
 * Attributes [parent] and [children] are read-only. Use the methods instead.
 *
 * See http://en.wikipedia.org/wiki/Scene_graph
 */
class SceneNode {

  SceneNode parent;
  List<SceneNode> children = [];

  /**
   * Add a [child] to this node.
   */
  void add(SceneNode child) {
    children.add(child);
    child.parent = this;
  }

}