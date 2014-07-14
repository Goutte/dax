library dax_tests_spatial_scene_node;

import 'dart:math';
import 'package:color/color.dart';
import 'package:unittest/unittest.dart';

import 'package:vector_math/vector_math.dart';

import '../../lib/dax.dart';


/// ----------------------------------------------------------------------------

/**
 * Matcher for equality between two Vector3, with optional [tolerance].
 */
class IsVector3Matcher extends Matcher {
  num x, y, z;
  num tolerance;
  IsVector3Matcher(num this.x, num this.y, num this.z, [num this.tolerance = 0.0]);
  bool matches(Vector3 v, Map matchState) {
    return (v.x - x).abs() <= tolerance &&
           (v.y - y).abs() <= tolerance &&
           (v.z - z).abs() <= tolerance;
  }
  Description describe(Description description) =>
    description.addDescriptionOf(new Vector3(x,y,z));
}

Matcher isVector3(num x, num y, num z) => new IsVector3Matcher(x,y,z);
Matcher ishVector3(num x, num y, num z) => new IsVector3Matcher(x,y,z,1e-15);


/// ----------------------------------------------------------------------------


main() {


  test('has default spatial attributes', () {
    SpatialSceneNode node = new SpatialSceneNode();

    expect(node.position, isVector3(0.0,0.0,0.0));
    expect(node.direction, isVector3(0.0,0.0,-1.0));
    expect(node.up, isVector3(0.0,1.0,0.0));
  });


  test('can rotate in local space', () {
    SpatialSceneNode node = new SpatialSceneNode();

    node.rotate(O/2, new Vector3(0.0,1.0,0.0));

    // unchanged
    expect(node.position, isVector3(0.0,0.0,0.0));
    expect(node.up, isVector3(0.0,1.0,0.0));
    // changed
    expect(node.direction, ishVector3(0.0,0.0,1.0));

    node.rotate(O/4, new Vector3(0.0,1.0,0.0));

    expect(node.direction, ishVector3(1.0,0.0,0.0));
  });


}

