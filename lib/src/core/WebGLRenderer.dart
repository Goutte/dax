part of dax;


class WebGLRenderer extends Renderer {

  WebGL.RenderingContext gl;

  Map<String, ShaderProgram> _materialShaderPrograms = {};

  Map<Model, WebGL.Buffer> verticesBuffers = {};

  WebGLRenderer(WebGL.RenderingContext this.gl);


  /**
   * Draws the [world].
   * Traverses all SceneNodes of its SceneGraph, and renders the renderable.
   */
  void draw(World world) {
    // World's cosmic background color is the clear() color
    Color background = world.background;
    gl.clearColor(background.r, background.g, background.b, 1.0);
    gl.clear(WebGL.COLOR_BUFFER_BIT | WebGL.DEPTH_BUFFER_BIT);
    _drawNode(world.root, world);
  }

  /**
   * Recursively draws this [node] and its children.
   * Parent-first ; this traversal is highly arbitrary,
   * ... I don't know what I'm doing.
   */
  void _drawNode(SceneNode node, World world) {
    if (node is Model) {
      _drawModel(node, world);
    }
    for (SceneNode child in node.children) {
      _drawNode(child, world);
    }
  }

  void _drawModel(Model model, World world) {

    if (model.mesh == null) return;

    _initModelVerticesBuffer(model);

    if (_materialShaderPrograms[model.material.name] == null) {

      Shader vertex = model.material.vertex;
      Shader fragment = model.material.fragment;

      _materialShaderPrograms[model.material.name] = new ShaderProgram(
          fragment.toString(),
          vertex.toString(),
          gl,
          model.material.attributes,
          model.material.uniforms
      );

    }

    // Setup material variables from onSetup() layers hooks
    model.material.setupLayersIfNecessary(world, model, this);

    ShaderProgram shaderProgram = _materialShaderPrograms[model.material.name];

    gl.useProgram(shaderProgram.program);

    // Update material variables from onDraw() layers hooks
    for (MaterialLayer layer in model.material.layers) {
      Map<String, dynamic> valuesMap = layer.onDraw(world, model, this);
      model.material.setLayerVariables(layer, valuesMap);
    }

    // Set material variables into the shader program
    for (String variableName in model.material.values.keys) {
      if (shaderProgram.uniforms.containsKey(variableName)) {
        shaderProgram.setUniform(gl, shaderProgram.uniforms[variableName], model.material.values[variableName]);
      } else if (shaderProgram.attributes.containsKey(variableName)) {
        shaderProgram.setAttribute(gl, shaderProgram.attributes[variableName], model.material.values[variableName]);
      } else {
        throw new Exception("Unknown variable '${variableName}' in Material ${model.material.name}");
      }
    }

    _drawMesh(model);

  }

  /**
   * Draws this Model [node]'s mesh.
   */
  void _drawMesh(Model node) {
    // bindBuffer() tells the WebGL system the target of call to drawArrays
    gl.bindBuffer(WebGL.ARRAY_BUFFER, verticesBuffers[node]);
    gl.drawArrays(node.mesh.drawMode, 0, node.mesh.verticesCount);
  }

  void _initModelVerticesBuffer(Model node) {
    if (! verticesBuffers.containsKey(node)) {
      // Allocate and build the vertices buffer.
      // createBuffer() asks the WebGL system to allocate some data for us
      verticesBuffers[node] = gl.createBuffer();
      // bindBuffer() tells the WebGL system the target of call to bufferDataTyped
      gl.bindBuffer(WebGL.ARRAY_BUFFER, verticesBuffers[node]);
      gl.bufferDataTyped(WebGL.ARRAY_BUFFER, new Float32List.fromList(node.mesh.vertices), WebGL.STATIC_DRAW);
    }
  }

}