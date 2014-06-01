module components.collider;

import gl3n.linalg;

import components.relation;
import entity;


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
  
  // what entity did this collider spawn from? 
  // need to know since we do not want npcs firing bullets to get hit by their own bullets
  Entity spawner; 
  
  this(vec2[] vertices, ColliderType type)
  {
    // TODO: ensure verts are in order and defines a convex polygon
    this.vertices = vertices;
    this.type = type;
  }
}
