library dax_tests;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'core/Material.dart' as MaterialTests;
import 'core/SceneGraph.dart' as SceneGraphTests;
import 'core/Shader.dart' as ShaderTests;
import 'core/SpatialSceneNode.dart' as SpatialSceneNodeTests;

// This main runner summarizes all runs in the browser. Just open runner.html

/// ----------------------------------------------------------------------------

// Matchers
// https://www.dartlang.org/articles/dart-unit-tests/#matchers

main() {
  useHtmlEnhancedConfiguration();
  unittestConfiguration.timeout = new Duration(seconds: 3);

  group('Material', MaterialTests.main);
  group('SceneGraph', SceneGraphTests.main);
  group('Shader', ShaderTests.main);
  group('SpatialSceneNode', SpatialSceneNodeTests.main);
}
