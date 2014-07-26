part of dax;


/**
 * Intended as an Interface for a SceneNode.
 * The Renderer will check if the node is Renderable
 * while traversing the SceneGraph, and if it is, it will render the mesh.
 */
abstract class Renderable {
  Mesh get mesh;
}


/**
 * Intended as an Interface for a SceneNode.
 * The Renderer will check if the node is Shadable
 * while traversing the SceneGraph, and if it is, it will render the material.
 */
abstract class Shadable {
  Material get material;
}