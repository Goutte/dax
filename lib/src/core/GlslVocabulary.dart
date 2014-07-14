part of dax;


class GlslVariable {
  String name;
  String type;

  GlslVariable(this.type, this.name);

  operator == (GlslVariable other) {
    return type == other.type && name == other.name;
  }
}


class GlslUniform extends GlslVariable {
  GlslUniform(type, name) : super(type, name);
}


class GlslAttribute extends GlslVariable {
  GlslAttribute(type, name) : super(type, name);
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