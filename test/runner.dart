library dax_tests;

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'core/SceneGraph.dart' as SceneGraphTests;
import 'core/Material.dart' as MaterialTests;
import 'core/Shader.dart' as ShaderTests;
import 'core/SpatialSceneNode.dart' as SpatialSceneNodeTests;

// The good thing with this form of factorization of unit tests
// is that each file can be ran independently in CLI or IDE,
// and this main runner summarizes all runs in the browser.

/// ----------------------------------------------------------------------------

// Matchers
// https://www.dartlang.org/articles/dart-unit-tests/#matchers


main() {
  useHtmlEnhancedConfiguration();
  unittestConfiguration.timeout = new Duration(seconds: 3);

  group('SceneGraph', SceneGraphTests.main);
  group('Material', MaterialTests.main);
  group('Shader', ShaderTests.main);
  group('SpatialSceneNode', SpatialSceneNodeTests.main);
}
