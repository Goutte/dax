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
  Map<String, WebGL.Buffer> attributesBuffers = {};

  /// [uniforms] : Global variables that may change per primitive
  /// (and may not be set inside glBegin/glEnd)
  /// that are passed from the OpenGL application to the shaders.
  /// These qualifiers can be used in both vertex and fragment shaders.
  /// For the shaders these are read-only variables.
  Map<String, GlslUniform> uniforms = {};
  Map<String, WebGL.UniformLocation> uniformsLocations = {};


  Map<Texture, WebGL.Texture> textures = {};

  WebGL.Program program;
  WebGL.Shader fragmentShader, vertexShader;

  ShaderProgram(String fragmentGlsl, String vertexGlsl,
                WebGL.RenderingContext gl,
                List<GlslAttribute> attributes,
                List<GlslUniform> uniforms)
  {
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
      print("Could not initialize shaders!");
      print("FRAGMENT :\n${fragmentGlsl}");
      print("VERTEX :\n${vertexGlsl}");
      //print("gl.getError() returns ${gl.getError()}");
      print("Program info log : ${gl.getProgramInfoLog(program)}");
      print("Fragment info log : ${gl.getShaderInfoLog(fragmentShader)}");
      print("Vertex info log : ${gl.getShaderInfoLog(vertexShader)}");
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


  void setAttribute(WebGL.RenderingContext gl, GlslAttribute attribute, List value) {
    var location = attributesLocations[attribute.name];

//    if (!attributesBuffers.containsKey(attribute.name)) {
    // fixme: don't re-create a GL buffer ! instead, cache it using value's HashCode (or something)
    // createBuffer() asks the WebGL system to allocate some data for us
    attributesBuffers[attribute.name] = gl.createBuffer();
    // bindBuffer() tells the WebGL system the target of call to bufferDataTyped
    gl.bindBuffer(WebGL.ARRAY_BUFFER, attributesBuffers[attribute.name]);
    gl.bufferDataTyped(WebGL.ARRAY_BUFFER, new Float32List.fromList(value), WebGL.STATIC_DRAW);
//    }

    WebGL.Buffer buffer = attributesBuffers[attribute.name];

    gl.bindBuffer(WebGL.ARRAY_BUFFER, buffer);

    return gl.vertexAttribPointer(location, attribute.size, WebGL.FLOAT, false, 0, 0);
  }

  int _iTest = -1;

  void setUniform(WebGL.RenderingContext gl, GlslUniform variable, value) {

    var location = uniformsLocations[variable.name];

//    print("set uniform ${variable.name}");
    
    switch (variable.type) {
      case 'float':
        return gl.uniform1f(location, value);
      case 'bool':
      case 'int':
//        print("setUniform int ${value}");
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
      case 'sampler2D':
        if (value is BitmapTexture) {
          int target = value.target;
          WebGL.Texture handle;

//          if (textures.containsKey(value)) {
//            handle = textures[value];
//          } else {

            handle = gl.createTexture();

            gl.bindTexture(target, handle);

            gl.texParameteri(target, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
            gl.texParameteri(target, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);
            gl.texParameteri(target, WebGL.TEXTURE_MAG_FILTER, WebGL.NEAREST);
            gl.texParameteri(target, WebGL.TEXTURE_MIN_FILTER, WebGL.NEAREST);

            try {
              if (value.isLoaded || true) {
                // Upload the texture bitmap data to the GPU.
                gl.texImage2D(target, 0, WebGL.RGBA, WebGL.RGBA, WebGL.UNSIGNED_BYTE, value.image);
              } else {
                //gl.texImage2D(target, 0, WebGL.RGBA, WebGL.RGBA, WebGL.UNSIGNED_BYTE, null);
//                print("Texture's image still not loaded.");
              }
            } catch (e) {
              print('Failed to upload the texture data to the GPU : ${e}');
            }

            //gl.pixelStorei(WebGL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, WebGL.ONE);

//            gl.pixelStorei GL_UNPACK_FLIP_Y_WEBGL, attrs.flip_y
//            conversion = if attrs.colorspace_conversion then GL_BROWSER_DEFAULT_WEBGL else GL_NONE
//            gl.pixelStorei GL_UNPACK_COLORSPACE_CONVERSION_WEBGL, conversion


//          }

          gl.bindTexture(target, handle);
          return gl.uniform1i(location, 0); // fixme : textureIndex instead of 0 ?
        } else {
          throw new ArgumentError("sampler2D must be an instance of BitmapTexture");
        }
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