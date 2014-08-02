part of dax;


/**
 * A scene node is something to be added to the scene graph.
 * It may be Positionable, Renderable, Shadable.
 * Without any of these traits, a scene node is basically a convenience group
 * for sorting and recursive removal.
 *
 * Right now, children of a Positionable scene node do not have a relative
 * coordinates system to their parent, but i'd like them to in the future.
 * That would mean multiplying some more matrices and memoize them too.
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

  /**
   * Remove a [child] of this node.
   * If not found, yell.
   */
  void remove(SceneNode child) {
    if (children.contains(child)) {
      children.remove(child);
      child.parent = null;
    } else {
      throw new Exception("Tried to remove non-child $child.");
    }
  }

  /**
   * Removes all children of this node.
   */
  void removeChildren() {
    for (SceneNode child in children) {
      child.parent = null;
    }
    children.clear();
  }

}