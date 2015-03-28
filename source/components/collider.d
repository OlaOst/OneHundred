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
  GuiElement,
}

class Collider
{  
  bool isColliding;
  // TODO: what about a collisionresponse delegate here?
  
  vec3 position;
  vec3 velocity;
  vec3 contactPoint;
  vec3 force = vec3(0.0, 0.0, 0.0);
  double radius;
  double mass;
  
  ColliderType type;
  
  vec3[] vertices;
  
  // what entity did this collider spawn from? 
  // need to know since we do not want ships firing bullets to get hit by their own bullets
  Entity spawner;
  Collider[] overlappingColliders;
  
  long id;
  
  this(vec3[] vertices, ColliderType type, long id)
  {
    // TODO: ensure verts are in order and defines a convex polygon
    this.vertices = vertices;
    this.type = type;
    this.id = id;
  }
  
  override int opCmp(Object other)
  {
    if (this is other) return 0;
    if (other is null) return 1;
    if (typeid(this) == typeid(other)) return this.id < (cast(Collider)other).id;
    return 1;
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
    position = entity.get!vec3("position");
    velocity = entity.get!vec3("velocity");
    radius = entity.get!double("radius", entity.get!double("size"));
    mass = entity.get!double("mass");
  }
}
