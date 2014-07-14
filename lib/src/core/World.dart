part of dax;


/**
 * A World is a Scene Graph, with additional properties, like :
 *   - a [camera], added automatically as child node of [root].
 *   - the cosmic [background] color. (almost-blackness by default, same as ours)
 * ---
 * Might as well name it Universe or Cosmos.
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


//  void add(SceneNode node) {
//    super.add(node);
//    if (node is Model) {
//      node.material
//    }
//  }



}