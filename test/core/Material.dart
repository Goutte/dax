library dax_tests_material;

import 'package:unittest/unittest.dart';

import '../../lib/dax.dart';

/// ----------------------------------------------------------------------------

class TestMaterial extends Material {

  TestMaterial() {
    layers.add(new TestLayerA());
    layers.add(new TestLayerB());
  }

}


class TestLayerA extends MaterialLayer {
  String get glslFragment => """
precision mediump float;
void main(void) {}
  """;
  String get glslVertex => """
attribute vec3 aTest;
uniform mat4 uTest;

void main(void) {
    gl_Position = uTest * vec4(aTest, 1.0);
}
  """;
}

class TestLayerB extends MaterialLayer {
  String get glslFragment => """
precision mediump float;
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
    String expectedFragment = """

    """;
    expect(material.fragment is Shader, isTrue);
    expect(material.vertex is Shader, isTrue);

    print(material.vertex);
    print(material.fragment);
  });


}

