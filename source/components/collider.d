module components.collider;

import gl3n.linalg;

import components.relation;


enum ColliderType
{
  Player,
  Npc,
  Bullet,
  Cursor,
}

class Collider
{  
  bool isColliding;
  // TODO: what about a collisionresponse delegate here?
  
  vec2 contactPoint;
  vec2 force = vec2(0.0, 0.0);
  //double radius;
  
  ColliderType type;
  
  vec2[] vertices;
  
  this(vec2[] vertices, ColliderType type)
  {
    // TODO: ensure verts are in order and defines a convex polygon
    this.vertices = vertices;
    this.type = type;
  }
}
