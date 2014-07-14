library dax_tests_scene_graph;

import 'package:unittest/unittest.dart';

import '../../lib/dax.dart';

/// ----------------------------------------------------------------------------

main() {


  test('has a root node', () {
    SceneGraph scene = new SceneGraph();
    expect(scene.root is SceneNode, isTrue);
  });


  test('accepts adding new nodes, as children of root', () {
    SceneGraph scene = new SceneGraph();
    SceneNode node = new SceneNode();
    scene.add(node);

    expect(scene.root.children, hasLength(1));
    expect(scene.root.children, contains(node));
    expect(node.parent, equals(scene.root));
  });


}

