library dax_tests_shader;

import 'package:unittest/unittest.dart';

import '../../lib/dax.dart';

/// ----------------------------------------------------------------------------

main() {

  test('parses a simple GLSL and extracts information', () {
    String glsl = """
attribute vec3 aVertexPosition;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;

void main (void) {
    gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
}
    """;

    Shader shader = new Shader(glsl);

    expect(shader.uniforms, contains(new GlslUniform('mat4', 'uMVMatrix')));
    expect(shader.uniforms, contains(new GlslUniform('mat4', 'uPMatrix')));
    expect(shader.attributes, contains(new GlslAttribute('vec3', 'aVertexPosition')));
    expect(shader.main.contents, equalsIgnoringWhitespace("""
    gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
    """));
  });


}

