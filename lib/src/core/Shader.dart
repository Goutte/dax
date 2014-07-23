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

  /// All uniforms, attributes and varyings.
  /// Re-collects the list each time.
  List<GlslVariable> get variables => _collectVariables();

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

  List<GlslVariable> _collectVariables() {
    List<GlslVariable> _variables = [];
    for (GlslAttribute attribute in attributes) {
      _variables.add(attribute);
    }
    for (GlslUniform uniform in uniforms) {
      _variables.add(uniform);
    }
    for (GlslVarying varying in varyings) {
      _variables.add(varying);
    }
    return _variables;
  }

  _parseGlsl(String glsl) {

    // `.` does not match carriage returns, even with multiLine, but \s does.
    RegExp attributeRegex = new RegExp(
        r"(shared|)\s*attribute\s+([\w]+)\s+((?:[\w]+\s*,?\s*)+);", multiLine: true);
    RegExp uniformRegex = new RegExp(
        r"(shared|)\s*uniform\s+([\w]+)\s+((?:[\w]+\s*,?\s*)+);", multiLine: true);
    RegExp varyingRegex = new RegExp(
        r"(shared|)\s*varying\s+([\w]+)\s+((?:[\w]+\s*,?\s*)+);", multiLine: true);
    RegExp mainRegex = new RegExp(
        r"void main\s*\([^)]*\)\s*\{((?:.|\s)*)\}", multiLine: true);

    // List of [start, end] so that we may collect all not-regex-collected code.
    List weGotIt = [];

    for (Match match in attributeRegex.allMatches(glsl)) {
      weGotIt.add([match.start, match.end]);
      bool shared = match.group(1).isNotEmpty;
      String type = match.group(2);
      List names = match.group(3).split(",");
      for (String name in names) {
        GlslAttribute attribute = new GlslAttribute(type, name.trim());
        attribute.shared = shared;
        attributes.add(attribute);
      }
    }

    for (Match match in uniformRegex.allMatches(glsl)) {
      weGotIt.add([match.start, match.end]);
      bool shared = match.group(1).isNotEmpty;
      String type = match.group(2);
      List names = match.group(3).split(",");
      for (String name in names) {
        GlslUniform uniform = new GlslUniform(type, name.trim());
        uniform.shared = shared;
        uniforms.add(uniform);
      }
    }

    for (Match match in varyingRegex.allMatches(glsl)) {
      weGotIt.add([match.start, match.end]);
      bool shared = match.group(1).isNotEmpty;
      String type = match.group(2);
      List names = match.group(3).split(",");
      for (String name in names) {
        GlslVarying varying = new GlslVarying(type, name.trim());
        varying.shared = shared;
        varyings.add(varying);
      }
    }

    if (mainRegex.hasMatch(glsl)) {
      Match match = mainRegex.firstMatch(glsl);
      weGotIt.add([match.start, match.end]);
      String contents = match.group(1);
      main = new GlslMain(contents);
    }

    weGotIt.sort((List a, List b) => a[0].compareTo(b[0]));

    other = '';
    int s = 0;
    for (List startEnd in weGotIt) {
      int e = startEnd[0];
      if (s < e) {
        other += glsl.substring(s, e).trim() + "\n";
      }
      s = startEnd[1];
    }
    other = other;

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