module components.collider;

import std.algorithm;
import std.array;

import gl3n.linalg;

import collision.check;
import components.relation;
import entity;


enum ColliderType
{
  Player,
  Npc,
  Bullet,
  Cursor,
}

struct Collider
{  
  bool isColliding;
  // TODO: what about a collisionresponse delegate here?
  
  Collider[] overlappingColliders;
  
  vec2 position;
  vec2 velocity;
  vec2 contactPoint;
  vec2 force = vec2(0.0, 0.0);
  double radius;
  
  ColliderType type;
  
  vec2[] vertices;
  
  // what entity did this collider spawn from? 
  // need to know since we do not want npcs firing bullets to get hit by their own bullets
  Entity spawner; 
  
  //bool toBeRemoved = false;
  long id;
  
  this(vec2[] vertices, ColliderType type, long id)
  {
    // TODO: ensure verts are in order and defines a convex polygon
    this.vertices = vertices;
    this.type = type;
    this.id = id;
  }
  
  /*bool opEquals(const Collider other)
  {
    return this.id == other.id;
  }
  
  bool opEquals(ref const Collider other)
  {
    return this.id == other.id;
  }
  
  bool opEquals(const Collider other) const
  {
    return this.id == other.id;
  }*/
  
  bool isOverlapping(Collider other)
  {
    //assert(other !is null);
    
    if ((position - other.position).magnitude_squared < (radius + other.radius)^^2)
    {
      //auto firstCollider = this;
      //auto otherCollider = other;
      
      //assert(firstCollider !is null && otherCollider !is null);
      
      auto firstVertices = vertices.map!(vertex => vertex + position).array();
      auto otherVertices = other.vertices.map!(vertex => vertex + other.position).array();
      
      return firstVertices.isOverlapping(otherVertices, velocity, other.velocity) ||
             otherVertices.isOverlapping(firstVertices, other.velocity, velocity);      
    }
    return false;
  }
}
