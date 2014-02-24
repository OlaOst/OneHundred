module component.collider;

import artemisd.all;
import gl3n.linalg;

import component.relation;


final class Collider : Component
{
  mixin TypeDecl;
  
  bool isColliding;
  vec2 contactPoint;
  vec2 force;
  //double radius;
  
  vec2[] vertices;
  
  this(vec2[] vertices)
  {
    // TODO: ensure verts are in order and defines a convex polygon
    this.vertices = vertices;
  }
}
