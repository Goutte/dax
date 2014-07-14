part of dax;

/**
 * A small wrapper for `WebGL.Program`.
 */
class ShaderProgram {

  /// [attributes] : Global variables that may change per vertex,
  /// that are passed from the OpenGL application to vertex shaders.
  /// These qualifiers can only be used in vertex shaders.
  /// For the shader these are read-only variables.
  Map<String, GlslAttribute> attributes = {};
  Map<String, int> attributesLocations = {};

  /// [uniforms] : Global variables that may change per primitive
  /// (and may not be set inside glBegin/glEnd)
  /// that are passed from the OpenGL application to the shaders.
  /// These qualifiers can be used in both vertex and fragment shaders.
  /// For the shaders these are read-only variables.
  Map<String, GlslUniform> uniforms = {};
  Map<String, WebGL.UniformLocation> uniformsLocations = {};

  WebGL.Program program;
  WebGL.Shader fragmentShader, vertexShader;

  ShaderProgram(String fragmentGlsl, String vertexGlsl,
                WebGL.RenderingContext gl,
                List<GlslAttribute> attributes,
                List<GlslUniform> uniforms)
  {

    print("FRAGMENT :\n${fragmentGlsl}");
    print("VERTEX :\n${vertexGlsl}");

    fragmentShader = gl.createShader(WebGL.FRAGMENT_SHADER);
    gl.shaderSource(fragmentShader, fragmentGlsl);
    gl.compileShader(fragmentShader);

    vertexShader = gl.createShader(WebGL.VERTEX_SHADER);
    gl.shaderSource(vertexShader, vertexGlsl);
    gl.compileShader(vertexShader);

    program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);

    if (!gl.getProgramParameter(program, WebGL.LINK_STATUS)) {
      print("Could not initialize shaders");
    }

    for (GlslAttribute attribute in attributes) {
      int attributeLocation = gl.getAttribLocation(program, attribute.name);
      gl.enableVertexAttribArray(attributeLocation);
      this.attributes[attribute.name] = attribute;
      attributesLocations[attribute.name] = attributeLocation;
    }
    for (GlslUniform uniform in uniforms) {
      var uniformLocation = gl.getUniformLocation(program, uniform.name);
      this.uniforms[uniform.name] = uniform;
      uniformsLocations[uniform.name] = uniformLocation;
    }
  }


  void setAttribute(WebGL.RenderingContext gl, GlslAttribute variable, value) {
    var location = attributesLocations[variable.name];

    gl.bindBuffer(WebGL.ARRAY_BUFFER, value);

    return gl.vertexAttribPointer(location, 3, WebGL.FLOAT, false, 0, 0);
  }

  void setUniform(WebGL.RenderingContext gl, GlslUniform variable, value) {

    var location = uniformsLocations[variable.name];
    
    switch (variable.type) {
      case 'float':
        return gl.uniform1f(location, value);
      case 'bool':
      case 'int':
        return gl.uniform1i(location, value);
      case 'vec2':
        return gl.uniform2fv(location, value);
      case 'vec3':
        return gl.uniform3fv(location, value);
      case 'vec4':
        return gl.uniform4fv(location, value);
      case 'bvec2':
      case 'ivec2':
        return gl.uniform2iv(location, value);
      case 'bvec3':
      case 'ivec3':
        return gl.uniform3iv(location, value);
      case 'bvec4':
      case 'ivec4':
        return gl.uniform4iv(location, value);
      case 'mat2':
        return gl.uniformMatrix2fv(location, false, value);
      case 'mat3':
        return gl.uniformMatrix3fv(location, false, value);
      case 'mat4':
        return gl.uniformMatrix4fv(location, false, value);

      // todo : textures !
//      case 'sampler2D':
//      case 'samplerCube':
//        if (!(value instanceof Jax.Texture) || value.ready()) {
//          gl.activeTexture(GL_TEXTURE0 + this.__textureIndex);
//          if (!value.isValid(context)) {
//            value.refresh(context);
//          }
//          gl.bindTexture(value.options.target, value.getHandle(context));
//          return gl.uniform1i(location, value = this.__textureIndex++);
//        }
//        break;

      default:
        throw new Exception("Unexpected uniform type: '${variable.type}'.");
    }

  }


}