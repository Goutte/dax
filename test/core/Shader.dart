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

  test('supports big glsl shaders', () {
    String long = "";
    for (int i = 0; i < 512; i++) {
      long += "aVeryLongInstructionWithLotsOfCharacters(vec3(0.1241546645647, 1.4596418744545634, 5.459785634524));\n";
    }
    String glsl = """
void main (void) {
    $long
}
    """;

    Shader shader = new Shader(glsl);

    expect(shader.main.contents, equalsIgnoringWhitespace(long));
  });


}

