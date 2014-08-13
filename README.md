
Overview
========

Dax is an experimental framework for developing WebGL-enabled applications using Dart.
It is shamelessly ripped off [Jax](https://github.com/sinisterchipmunk/jax), hence the name.

It has very few features at this point, and most of them were obtained by
randomly typing on a keyboard until something happened on-screen.

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

We *need* the DEPTH_TEST. Alternatives: render back-to-front model-wise (banana problems)
For simplicity, we're going to ignore transparency for now.

When we'll want some :

- Activate BLEND (keep DEPTH_TEST)
- Render the opaques
- Render the transps (back-to-front order, model-wise)
- Octree !
- Manage somehow special case : transps with boundingboxes collisions (banana!)

Not implemented
===============

Features you'd expect but have not been implemented.

(pick one, hack one)

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
