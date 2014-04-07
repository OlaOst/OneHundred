module component.collider;

import gl3n.linalg;

import component.relation;


class Collider
{  
  bool isColliding;
  vec2 contactPoint;
  vec2 force = vec2(0.0, 0.0);
  //double radius;
  
  vec2[] vertices;
  
  this(vec2[] vertices)
  {
    // TODO: ensure verts are in order and defines a convex polygon
    this.vertices = vertices;
  }
}
