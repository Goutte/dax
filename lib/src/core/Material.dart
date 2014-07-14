part of dax;


/**
 * A Model owns a Material that holds shader information.
 * A Material is made of MaterialLayers, which are their own ShaderProgram.
 *
 * A Material merges the layers' shaders into one shader, and also takes care of
 * the attributes, uniforms and varyings.
 *
 * WARNING :
 * The preprocessor is still quite dumb, and ignores all extra code
 * outside of the main that is not attribute/uniform declaration.
 * Therefore, #includes don't not work (yet).
 */
class Material {

  List<MaterialLayer> layers = [];

  Shader _vertex;
  Shader _fragment;

  Shader get vertex => _generateVertexShader();
  Shader get fragment => _generateFragmentShader();

  List<GlslAttribute> get attributes => _collectAttributes();
  List<GlslUniform> get uniforms => _collectUniforms();

  String get name => this.runtimeType.toString();

  /// The [values] of the uniforms and attributes passed to the shader,
  /// indexed by their mangled variable name.
  /// You can change this whenever you want using setLayerVariable(),
  /// but not by editing this Map directly, unless you mangle the key yourself.
  Map<String, dynamic> values = {};

  /// CONSTRUCTORS -------------------------------------------------------------

  Material();

  /// API ----------------------------------------------------------------------

  /**
   * Returns the layer described by its [layerName].
   * If no layer is found with that name in this Material, it throws.
   */
  MaterialLayer getLayer(String layerName) {
    for (MaterialLayer layer in layers) {
      if (layer.name == layerName) return layer;
    }
    throw new Exception("Layer '${layerName}' was not found in ${name}.");
  }

  /**
   * Sets [layerName]'s [variableName] to [value].
   * This can be used both for attributes and uniforms.
   * Optionally, you may want to not [clobber] an existing value.
   */
  void setLayerVariable(String layerName, String variableName, value,
                        {bool clobber: true}) {
    MaterialLayer layer = getLayer(layerName); // also checks existence of layer
    _setLayerVariable(layer, variableName, value, clobber: clobber);
  }

  void setLayerVariables(MaterialLayer layer, Map<String, dynamic> valuesMap,
                         {bool clobber: true}) {
    for (String variableName in valuesMap.keys) {
      _setLayerVariable(layer, variableName, valuesMap[variableName],
                        clobber: clobber);
    }
  }


  bool _areLayersSetup = false;
  void setupLayersIfNecessary(World world, Model model, Renderer renderer) {
    if (! _areLayersSetup) {
      _areLayersSetup = true;
      for (MaterialLayer layer in layers) {
        Map<String, dynamic> valuesMap = layer.onSetup(world, model, this);
        setLayerVariables(layer, valuesMap, clobber: false);
      }
    }
  }


  /// PRIVVIES -----------------------------------------------------------------

  void _setLayerVariable(MaterialLayer layer, String variableName, value,
                         {bool clobber: true}) {
    if (value is Vector2 ||
        value is Vector3 ||
        value is Vector4 ||
        value is Matrix2 ||
        value is Matrix3 ||
        value is Matrix4 ) {
      value = value.storage;
    } else if (value is List && !(value is TypedData)) {
      value = new Float32List.fromList(value);
    }
    String mangledName = "${layer.name}_${variableName}";
    if (clobber || !values.containsKey(mangledName)) {
      values[mangledName] = value;
    }
  }

  List<GlslAttribute> _collectAttributes() {
    List<GlslAttribute> attributes = [];
    attributes.addAll(fragment.attributes);
    attributes.addAll(vertex.attributes);
    return attributes;
  }

  List<GlslUniform> _collectUniforms() {
    List<GlslUniform> uniforms = [];
    uniforms.addAll(fragment.uniforms);
    uniforms.addAll(vertex.uniforms);
    return uniforms;
  }

  void _checkLayersUnicity() {
    List<String> uniqueIds = [];
    for (MaterialLayer layer in layers) {
      if (uniqueIds.contains(layer.uid)) {
        // this may be supported in the future, thus negating the need for this.
        throw new UnsupportedError("${name} contains more than 1 ${layer.uid}");
      }
      uniqueIds.add(layer.uid);
    }
  }

  Shader _generateVertexShader() {
    if (_vertex != null) return _vertex;

    _checkLayersUnicity();

    _vertex = new Shader();
    _vertex.main = new GlslMain();

    // todo: 1st pass to check for possible mangledName collisions
    for (MaterialLayer layer in layers) {
      _mergeShaders(layer.uid, layer.vertex, _vertex);
    }

    return _vertex;
  }


  Shader _generateFragmentShader() {
    if (_fragment != null) return _fragment;

    _checkLayersUnicity();

    _fragment = new FragmentShader();
    _fragment.main = new GlslMain();

    // todo: 1st pass to check for possible mangledName collisions
    for (MaterialLayer layer in layers) {
      _mergeShaders(layer.uid, layer.fragment, _fragment);
    }

    return _fragment;
  }


  Shader _mergeShaders(String uid, Shader from, Shader into) {
    String mangledContents = '';
    if (from.main != null) {
      mangledContents = from.main.contents;
    }

    for (GlslAttribute attribute in from.attributes) {
      String mangledName = uid + '_' + attribute.name;
      GlslAttribute mangledAttribute = new GlslAttribute(attribute.type, mangledName);
      into.attributes.add(mangledAttribute);
      mangledContents = mangledContents.replaceAllMapped(
          new RegExp(r"(\b)("+attribute.name+r")(\b)"),
          (Match m) => "${m[1]}${mangledName}${m[3]}");
    }

    for (GlslUniform uniform in from.uniforms) {
      String mangledName = uid + '_' + uniform.name;
      GlslUniform mangledUniform = new GlslUniform(uniform.type, mangledName);
      into.uniforms.add(mangledUniform);
      mangledContents = mangledContents.replaceAllMapped(
          new RegExp(r"(\b)("+uniform.name+r")(\b)"),
          (Match m) => "${m[1]}${mangledName}${m[3]}");
    }

    into.other += "void main_${uid}(void) {${mangledContents}}\n";
    into.main.contents += "main_${uid}();\n";
  }

  /// TESTING UTILS ------------------------------------------------------------

}

