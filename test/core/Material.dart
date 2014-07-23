library dax_tests_material;

import 'package:unittest/unittest.dart';

import '../../lib/dax.dart';


/**
 * Showcases the features of dax's glsl parser when making shaders layers
 * for our materials.
 *
 * Supports :
 * - mangling of :
 *   - main()
 *   - attribute
 *   - uniform
 *   - varying
 * -
 * Todo support :
 * - varying int a, b, c;
 * - shared attribute
 * - shared uniform
 * - shared varying
 * - include
 */


/// ----------------------------------------------------------------------------


/**
 * A material composed of our two tricky layers, first A then B.
 */
class TestMaterial extends Material {

  TestMaterial() {
    layers.add(new TestLayerA());
    layers.add(new TestLayerB());
  }

}


class TestLayerA extends MaterialLayer {
  String get glslFragment => """
varying vec3 vPos;

void main(void) {}
  """;
  String get glslVertex => """
attribute vec3 aTest;
attribute vec3 aOne, aTwo, aKri;
uniform vec3 u1, u2, u3;
uniform mat4 uTest;
varying vec3 vPos;
varying vec3 v_uno, v_dos, v_kro;

void main(void) {
    gl_Position = uTest * vec4(aTest, 1.0);
    vPos = aTest.xyz;
}
  """;
}

class TestLayerB extends MaterialLayer {
  String get glslFragment => """
uniform vec3 uGlobalColor;

void main(void) {
    gl_FragColor = vec4(uGlobalColor, 1.0);
}
  """;
  String get glslVertex => """
uniform mat4 uTest;
void main(void) {
    // nothing
}
  """;
}

/// ----------------------------------------------------------------------------

main() {


  test('merges layers GLSL', () {
    Material material = new TestMaterial();
    String expectedVertex = """
attribute vec3 TestLayerA_aTest;
attribute vec3 TestLayerA_aOne;
attribute vec3 TestLayerA_aTwo;
attribute vec3 TestLayerA_aKri;
uniform vec3 TestLayerA_u1;
uniform vec3 TestLayerA_u2;
uniform vec3 TestLayerA_u3;
uniform mat4 TestLayerA_uTest;
uniform mat4 TestLayerB_uTest;
varying vec3 TestLayerA_vPos;
varying vec3 TestLayerA_v_uno;
varying vec3 TestLayerA_v_dos;
varying vec3 TestLayerA_v_kro;

void main_TestLayerA(void) {
    gl_Position = TestLayerA_uTest * vec4(TestLayerA_aTest, 1.0);
    TestLayerA_vPos = TestLayerA_aTest.xyz;
}
void main_TestLayerB(void) {
    // nothing
}

void main(void) {
main_TestLayerA();
main_TestLayerB();
}
    """;
    String expectedFragment = """
precision mediump float;
precision mediump int;

uniform vec3 TestLayerB_uGlobalColor;
varying vec3 TestLayerA_vPos;

void main_TestLayerA(void) {}
void main_TestLayerB(void) {
    gl_FragColor = vec4(TestLayerB_uGlobalColor, 1.0);
}

void main(void) {
main_TestLayerA();
main_TestLayerB();
}
    """;
    expect(material.fragment is Shader, isTrue);
    expect(material.vertex is Shader, isTrue);

    print("== VERTEX SHADER ==");
    print(material.vertex);
    print("== FRAGMENT SHADER ==");
    print(material.fragment);

    expect(material.vertex.toString(), equalsIgnoringWhitespace(expectedVertex));
    expect(material.fragment.toString(), equalsIgnoringWhitespace(expectedFragment));

  });


}

