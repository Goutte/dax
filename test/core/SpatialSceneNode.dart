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


  /**
   * Student test, not really a dax test.
   */
  test('bitwise operators', () {
    int z = 0x000;
    int a = 0x001;
    int b = 0x002;
    int c = 0x004;
    int d = 0x008;
    int h = 0x080;

    expect(a & z > 0, isFalse);
    expect(a & b > 0, isFalse);
    expect(a & c > 0, isFalse);
    expect(a & d > 0, isFalse);
    expect(a & h > 0, isFalse);
    expect(h & z > 0, isFalse);
    expect(h & a > 0, isFalse);

    z |= a | b | h ;
    expect(z & a > 0, isTrue);
    expect(z & b > 0, isTrue);
    expect(z & h > 0, isTrue);

    z ^= b;
    expect(z & b > 0, isFalse);
    expect(z & h > 0, isTrue);
  });

}

