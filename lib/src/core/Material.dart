part of dax;


/**
 * A Model owns a Material that holds shader information.
 * A Material is made of MaterialLayers, which are their own ShaderProgram.
 *
 * A Material merges the layers' shaders into one shader, and also takes care of
 * the attributes, uniforms and varyings.
 *
 * WARNING :
 * The preprocessor is still quite dumb, and does not mangle all extra code
 * outside of the main that is not a GLSL variable declaration.
 * Also, #includes don't work (yet). They woumld be awesome.
 */
class Material {

  List<MaterialLayer> layers = [];

  Shader _vertex;
  Shader _fragment;
  /// Maps the names of the variables as defined in the layers' shaders to
  /// the names of the variable as defined in this material's shader.
  /// If two layers
//  Map<String, String> _mangledNames = {};

  Shader get vertex => _generateVertexShader();
  Shader get fragment => _generateFragmentShader();

  List<GlslAttribute> get attributes => _collectAttributes();
  List<GlslUniform> get uniforms => _collectUniforms();
  List<GlslVarying> get varyings => _collectVaryings();

  String get name => this.runtimeType.toString();

  /// The [values] of the uniforms and attributes passed to the shader,
  /// indexed by their mangled (or not, if shared) variable name.
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
  void setVariable(String layerName, String variableName, value,
                   {bool clobber: true}) {
    MaterialLayer layer = getLayer(layerName); // also checks existence of layer
    _setLayerVariable(layer, variableName, value, clobber: clobber);
  }

  /**
   * Sets [layer]'s [variableName] to [value].
   * This can be used both for attributes and uniforms.
   * Optionally, you may want to not [clobber] an existing value.
   */
  void setLayerVariable(MaterialLayer layer, String variableName, value,
                        {bool clobber: true}) {
    _setLayerVariable(layer, variableName, value, clobber: clobber);
  }

  /**
   * Sets [layer]'s variables according to [valuesMap], which maps
   * variable names to the values you want to set them to.
   * This can be used both for attributes and uniforms.
   * Optionally, you may want to not [clobber] existing variables.
   */
  void setLayerVariables(MaterialLayer layer, Map<String, dynamic> valuesMap,
                         {bool clobber: true}) {
    for (String variableName in valuesMap.keys) {
      _setLayerVariable(layer, variableName, valuesMap[variableName],
                        clobber: clobber);
    }
  }


  /**
   * Returns the mangled (if necessary, ie if not shared) name of [variableName]
   * defined [inLayer].
   */
  String getMangledName(String variableName, MaterialLayer inLayer) {
    return inLayer.getMangledName(variableName);
  }

  // unsure about this
  bool _areLayersSetup = false;
  void setupLayersIfNecessary(World world, Model model, Renderer renderer) {
    if (! _areLayersSetup) {
      _areLayersSetup = true;
      for (MaterialLayer layer in layers) {
        Map<String, dynamic> valuesMap = layer.onSetup(world, model, renderer);
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

    String mangledName = getMangledName(variableName, layer);

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

  List<GlslVarying> _collectVaryings() {
    List<GlslVarying> varyings = [];
    varyings.addAll(vertex.varyings);
    return varyings;
  }

  // this may be supported in the future, thus negating the need for this.
  void _checkLayersUnicity() {
    List<String> uniqueIds = [];
    for (MaterialLayer layer in layers) {
      if (uniqueIds.contains(layer.uid)) {
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

  /**
   * Merges [uid] (uniquely identified) shader [from], [into] another shader.
   *
   * Warning: this appends without mangling the `other`. Collisions WILL happen!
   */
  void _mergeShaders(String uid, Shader from, Shader into) {
    String mangledContents = '';
    if (from.main != null) {
      mangledContents = from.main.contents;
    }

    for (GlslAttribute attribute in from.attributes) {
      if (attribute.shared) {
        // if not already present (added by any previous layer)
        if (! into.attributes.contains(attribute)) {
          into.attributes.add(attribute);
        }
      } else {
        String mangledName = uid + '_' + attribute.name;
        GlslAttribute mangledAttribute = new GlslAttribute(attribute.type, mangledName);
        into.attributes.add(mangledAttribute);
        mangledContents = mangledContents.replaceAllMapped(
            new RegExp(r"(\b)("+attribute.name+r")(\b)"),
            (Match m) => "${m[1]}${mangledName}${m[3]}");
      }
    }

    for (GlslUniform uniform in from.uniforms) {
      if (uniform.shared) {
        // if not already present (added by any previous layer)
        if (! into.uniforms.contains(uniform)) {
          into.uniforms.add(uniform);
        }
      } else {
        String mangledName = uid + '_' + uniform.name;
        GlslUniform mangledUniform = new GlslUniform(uniform.type, mangledName);
        mangledUniform.arrayLength = uniform.arrayLength;
        into.uniforms.add(mangledUniform);
        mangledContents = mangledContents.replaceAllMapped(
            new RegExp(r"(\b)("+uniform.name+r")(\b)"),
            (Match m) => "${m[1]}${mangledName}${m[3]}");
      }
    }

    for (GlslVarying varying in from.varyings) {
      if (varying.shared) {
        // if not already present (added by any previous layer)
        if (! into.varyings.contains(varying)) {
          into.varyings.add(varying);
        }
      } else {
        String mangledName = uid + '_' + varying.name;
        GlslVarying mangledVarying = new GlslVarying(varying.type, mangledName);
        into.varyings.add(mangledVarying);
        mangledContents = mangledContents.replaceAllMapped(
            new RegExp(r"(\b)("+varying.name+r")(\b)"),
            (Match m) => "${m[1]}${mangledName}${m[3]}");
      }
    }

    // warning: collisions detected -- should also (somehow) mangle the other
    into.other += from.other;

    into.other += "void main_${uid}(void) {${mangledContents}}\n";
    into.main.contents += "main_${uid}();\n";
  }

  /// TESTING UTILS ------------------------------------------------------------

}

