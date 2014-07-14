library dax_tests;

import 'package:color/color.dart';
import 'package:unittest/unittest.dart';

import '../../lib/dax.dart';


/// COLOR EXPECTATIONS ---------------------------------------------------------


/**
 * Matcher for (exact) equality between two Colors.
 */
class IsColorMatcher extends Matcher {
  Color color;
  IsColorMatcher(Color this.color);
  bool matches(Color anotherColor, Map matchState) {
    return color == anotherColor;
  }
  Description describe(Description description) =>
    description.addDescriptionOf(color);
}

/**
 * Creates a Matcher for [color].
 * This is an alias for a more idiomatic use.
 */
Matcher isColor(Color color) {
  return new IsColorMatcher(color);
}

/**
 * Creates a Matcher for the [r], [g], [b] color.
 * This is an alias for a more idiomatic use :
 *
 *   expect(cosmos.background, isRgb(1,1,1));
 */
Matcher isRgb(int r, int g, int b) {
  return new IsColorMatcher(new Color.rgb(r,g,b));
}


/// ----------------------------------------------------------------------------


main() {


  test('is a SceneGraph', () {
    World world = new World();
    expect(world is SceneGraph, isTrue);
  });


  test('has an almost pitch-black cosmic background', () {
    World world = new World();
    expect(world.background is Color, isTrue);
    expect(world.background, isRgb(1,1,1));
  });


}

