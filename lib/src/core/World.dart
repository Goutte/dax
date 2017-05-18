part of dax;


/**
 * A World is a Scene Graph, with additional properties, like :
 *   - a [camera], added automatically as child node of [root].
 *   - the cosmic [background] color. (almost-blackness by default, same as ours)
 * ---
 * Might as well name it Universe or Cosmos? Bah, World is good.
 */
class World extends SceneGraph {

  Color background;
  Camera camera;

  World({ Color background, Camera camera }) : super() {
    if (background == null) {
      background = new Color.hex("#010101");
    }
    this.background = background;

    if (camera == null) {
      camera = new Camera();
    }
    this.camera = camera;

    this.root.add(camera);
  }

  /// API ----------------------------------------------------------------------

  /**
   * Traverses the nodes of this world, and calls the update() of Models.
   * The traversal is parent-first. (i still don't know what i'm doing)
   * Both [time] and [delta] should be in seconds. (to verify)
   */
  void update(num time, num delta) {
    _updateNodeAndChildren(root, time, delta);
  }

  /// PRIVVIES -----------------------------------------------------------------

  void _updateNodeAndChildren(SceneNode node, num time, num delta) {
    if (node is Updatable) {
      _updateUpdatable(node as Updatable, time, delta);
    }
    for (SceneNode child in node.children) {
      _updateNodeAndChildren(child, time, delta);
    }
  }

  void _updateUpdatable(Updatable model, num time, num delta) {
    model.update(time, delta);
  }

}