module components.collider;

import std.algorithm;
import std.array;

import gl3n.linalg;

import collision.check;
import converters;
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
  double mass;
  
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
  
  bool opEquals(const Collider other)
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
  }
  
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
  
  void updateFromEntity(const Entity entity)
  {
    if ("position" in entity.values)
      position = entity.values["position"].myTo!vec2;
    else
      position = vec2(0.0, 0.0);
    if ("velocity" in entity.values)
      velocity = entity.values["velocity"].myTo!vec2;
    else
      velocity = vec2(0.0, 0.0);
    if ("radius" in entity.values)
      radius = entity.values["radius"].to!double;
    else if ("size" in entity.values)
      radius = entity.values["size"].to!double;
    else
      radius = 0.0;
    if ("mass" in entity.values)
      mass = entity.values["mass"].to!double;
    else
      mass = 0.0;
  }
}
