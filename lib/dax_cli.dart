library dax_cli;

/// All the dax stuff that does not require dart:html and consorts.
/// Note that there still are things that are in dax that can safely be moved here.

import 'dart:math';

import 'package:vector_math/vector_math.dart';
import "package:range/range.dart";

part 'src/core/Color.dart';

/**
 * The circle constant, defined as the perimeter of the unit circle = 2*PI
 * See http://antoine.goutenoir.com/blog/2014/03/21/math-symbols-tau-pi-circle-constant/
 */
const double O = 6.2831853071795865;


/**
 * Mutates the [tuple] by rotating [offset] to the left, and then returns it.
 * The rotation is a circular one, meaning that during one step to the left,
 * the first element becomes the last element. The [offset] may be negative,
 * and in that case it will rotate to the right.
 *
 * Examples :
 *     tuple     off
 *   (0,1,2,3) ,  0  -> (0,1,2,3) # useless
 *   (0,1,2,3) ,  1  -> (1,2,3,0)
 *   (0,1,2,3) ,  2  -> (2,3,0,1)
 *   (0,1,2,3) , -1  -> (3,0,1,2)
 */
List rotateCycle(List tuple, int offset) {
  int n = tuple.length;
  offset = ((offset % n) + n) % n;
  num tmp;
  while (offset-- > 0) {
    tmp = tuple[0];
    for (int i in range(0, n-1)) {
      tuple[i] = tuple[i+1];
    }
    tuple[n-1] = tmp;
  }

  return tuple;
}