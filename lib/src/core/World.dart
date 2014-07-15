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

  World({ Color background }) : super() {
    if (background == null) {
      background = new Color.rgb(1,1,1);
    }
    this.background = background;

    this.camera = new Camera();
  }

  /// API ----------------------------------------------------------------------

  /**
   * Traverses the nodes of this world, and calls the update() of Models.
   * The traversal is parent-first. (i still don't know what i'm doing)
   */
  void update(num time, num delta) {
    _updateNode(root, time, delta);
  }

  /// PRIVVIES -----------------------------------------------------------------

  void _updateNode(SceneNode node, num time, num delta) {
    if (node is Model) {
      _updateModel(node, time, delta);
    }
    for (SceneNode child in node.children) {
      _updateNode(child, time, delta);
    }
  }

  void _updateModel(Model model, num time, num delta) {
    model.update(time, delta);
  }

}