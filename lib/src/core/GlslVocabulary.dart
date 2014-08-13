part of dax;


class GlslVariable {

  /// The [name] of the variable
  String name;

  /// The GLSL [type] of the variable
  String type;

  /// An array variable has a non-null [arrayLength]
  int arrayLength;

  /// A [shared] variable (between layers) does no submit to [name]-mangling.
  bool shared = false;

  /// The number of elements (floats, ints) of the [type] of this variable.
  int get size => _getSize();

  /// The additional '[42]' suffixing the variable declaration if it's an array.
  String get arraySuffix => _getArraySuffix();

  GlslVariable(this.type, this.name);

  operator == (GlslVariable other) {
    return type == other.type && name == other.name;
  }

  String _getArraySuffix() {
    return (arrayLength == null) ? '' : "[${arrayLength}]";
  }

  int _getSize() {
    switch (type) {
      case 'float':
      case 'bool':
      case 'int':
        return 1;
      case 'vec2':
      case 'bvec2':
      case 'ivec2':
        return 2;
      case 'vec3':
      case 'bvec3':
      case 'ivec3':
        return 3;
      case 'vec4':
      case 'bvec4':
      case 'ivec4':
      case 'mat2':
        return 4;
      case 'mat3':
        return 9;
      case 'mat4':
        return 16;
    }
    throw new UnsupportedError("Cannot get the size of ${type} ${name}.");
  }
}


class GlslUniform extends GlslVariable {
  GlslUniform(type, name) : super(type, name);
}


class GlslAttribute extends GlslVariable {
  GlslAttribute(type, name) : super(type, name);
}


class GlslVarying extends GlslVariable {
  GlslVarying(type, name) : super(type, name);
}


class GlslFunction {
  String name;
  String returnType;
  String contents;
}


class GlslMain extends GlslFunction {
  String name = 'main';
  String returnType = 'void';
  String contents = '';

  GlslMain([String this.contents = '']);
}