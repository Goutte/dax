part of dax;


/**
 * A Shader is a single vertex or fragment shader whose components have been
 * parsed and analysed, so that merging shaders is easier for the Material.
 *
 * - uniforms
 * - attributes
 * - main
 *
 * This uses Regexes to parse the GLSL, and those are pretty dumb right now.
 * Therefore, they may fail ; thankfully, there is a test-suite for that !
 *
 * WARNING: parsing will ignore code outside of main() that is not variable
 *          declaration, so beware !
 */
class Shader {

  List<GlslUniform> uniforms = [];
  List<GlslAttribute> attributes = [];
  List<GlslVarying> varyings = [];
  GlslMain main;

  /// Other miscellaneous code.
  /// This is filled during parsing (yet), but used by the material preprocessor
  /// This may be the place to put all the code that resides outside of main().
  String other = '';

  /// CONSTRUCTORS -------------------------------------------------------------

  Shader([String glsl = '']) {
    _parseGlsl(glsl);
  }

  /// HONEY --------------------------------------------------------------------

  /**
   * Generate the GLSL source code from the data of this Shader.
   * WARNING: may output less than the input [glsl].
   */
  String toString() {
    String s = "";

    for (GlslAttribute attribute in attributes) {
      s += "attribute ${attribute.type} ${attribute.name};\n";
    }

    for (GlslUniform uniform in uniforms) {
      s += "uniform ${uniform.type} ${uniform.name};\n";
    }

    for (GlslVarying varying in varyings) {
      s += "varying ${varying.type} ${varying.name};\n";
    }

    s += "\n${other}\n";

    if (main != null) {
      s += "void main(void) {\n${main.contents}}\n";
    }

    return s;
  }

  /// PRIVY --------------------------------------------------------------------

  _parseGlsl(String glsl) {

    // `.` does not match carriage returns, even with multiLine, but \s does.
    RegExp attributeRegex = new RegExp(
        r"attribute\s+([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)\s*;", multiLine: true);
    RegExp uniformRegex = new RegExp(
        r"uniform\s+([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)\s*;", multiLine: true);
    RegExp varyingRegex = new RegExp(
        r"varying\s+([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)\s*;", multiLine: true);
    RegExp mainRegex = new RegExp(
        r"main\s*\([^)]*\)\s*\{((?:.|\s)*)\}", multiLine: true);

    for (Match match in attributeRegex.allMatches(glsl)) {
      String type = match.group(1);
      String name = match.group(2);
      GlslAttribute attribute = new GlslAttribute(type, name);
      attributes.add(attribute);
    }

    for (Match match in uniformRegex.allMatches(glsl)) {
      String type = match.group(1);
      String name = match.group(2);
      GlslUniform uniform = new GlslUniform(type, name);
      uniforms.add(uniform);
    }

    for (Match match in varyingRegex.allMatches(glsl)) {
      String type = match.group(1);
      String name = match.group(2);
      GlslVarying varying = new GlslVarying(type, name);
      varyings.add(varying);
    }

    if (mainRegex.hasMatch(glsl)) {
      Match match = mainRegex.firstMatch(glsl);
      String contents = match.group(1);
      main = new GlslMain(contents);
    }

  }

}


class FragmentShader extends Shader {

  String toString() {
    String s = "precision mediump float;\nprecision mediump int;\n\n";
    s += super.toString();
    return s;
  }

}


class VertexShader extends Shader {}