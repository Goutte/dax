
Overview
========

Dax is an experimental framework for developing WebGL-enabled applications using Dart.
It is shamelessly ripped off [Jax](https://github.com/sinisterchipmunk/jax), hence the name.

It has very few features at this point, and most of them were obtained by
randomly typing on a keyboard until something happened on-screen.

This is a learner's project.

Furthermore, a lot of optimization is still required in present features,
I do not recommend using this as-is, unless you want to hack away with the lib,
which you're encouraged to do.

I have very basic needs, and I will only implement what I need.
Hopefully, these needs will grow with time, and so will the features of dax.


RoadMap
=======

The initial objective of dax is to provide enough features
to make a simple game like [Cyx](http://antoine.goutenoir.com/games/cyx/) or
[PlanetGL](http://planet.gl/).


Transparency
============

http://www.opengl.org/archives/resources/faq/technical/transparency.htm

We *need* the DEPTH_TEST.
Alternatives: render back-to-front, model-wise. (still, banana problems)
For simplicity, I'm ignoring transparency for now.

When we'll want some :

- Activate BLEND (keep DEPTH_TEST)
- Render the opaques
- Render the transps (back-to-front order, model-wise)
- Octree !
- Think about special case : transps with boundingboxes collisions (or banana!)

Not implemented
===============

Features you'd expect but have not been implemented.

(pick one, hack one)

- Shader variables GPU limitations detection and according shader layer dropping. (jax-style)
- Camera's Octree
- Lights
  - AmbientLight
  - SpotLight (extends SpatialSceneNode)
- more Meshes
- more Shaders


Dependencies
============

Libraries used (big thanks to their respective authors) :

- https://github.com/johnmccutchan/vector_math
  I forked this lib to add some more functions, but they're debatable so they're still in their fork.
  I suspect that glmatrix's signature approach fares better, performance-wise.
  If vector_math is adopted, it will probably move in that direction anyway.
  Keep a lookout for new dart math libs, as tree-shaking makes maths libs happy.