part of dax;


/**
 * A scene graph holds nodes.
 * It is automatically given a root node.
 *
 * tothink: this is a tree, specifically. Maybe rename ?
 *          also, this is missing so many features !
 *
 * See http://en.wikipedia.org/wiki/Scene_graph
 */
class SceneGraph {
  SceneNode root;

  SceneGraph(){
    root = new SceneNode();
  }

  /// Adds a new [node] to this scene graph, under [root].
  void add(SceneNode node) {
    if (node == null) throw new ArgumentError("Added node is null.");
    root.add(node);
  }

  /// Removes a [node] from the [root] of this scene graph.
  void remove(SceneNode node) {
    if (node == null) throw new ArgumentError("Removed node is null.");
    root.remove(node);
  }
}