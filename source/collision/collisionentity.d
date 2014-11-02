module collision.collisionentity;

import std.algorithm;
import std.array;

import gl3n.linalg;

import collision.check;
import entity;


/*struct CollisionEntity
{
  Entity entity;
  vec2 position;
  vec2 velocity;
  double radius;
  double mass;
  alias entity this;
  CollisionEntity[] overlappingEntities;
  
  this(Entity entity)
  {
    this.entity = entity;
    updateFromEntity();
  }
  
  bool isOverlapping(CollisionEntity other)
  {
    if ((position - other.position).magnitude_squared < (radius + other.radius)^^2)
    {
      auto firstCollider = entity.collider;
      auto otherCollider = other.entity.collider;
      
      assert(firstCollider !is null && otherCollider !is null);
      
      auto firstVertices = firstCollider.vertices.map!(vertex => vertex + position).array();
      auto otherVertices = otherCollider.vertices.map!(vertex => vertex + other.position).array();
      
      return firstVertices.isOverlapping(otherVertices, velocity, other.velocity) ||
             otherVertices.isOverlapping(firstVertices, other.velocity, velocity);      
    }
    return false;
  }
  
  void updateFromEntity()
  {
    if ("position" in entity.vectors)
      position = entity.vectors["position"];
    else
      position = vec2(0.0, 0.0);
    if ("velocity" in entity.vectors)
      velocity = entity.vectors["velocity"];
    else
      velocity = vec2(0.0, 0.0);
    if ("size" in entity.scalars)
      radius = entity.scalars["size"];
    else
      radius = 0.0;
    if ("mass" in entity.scalars)
      mass = entity.scalars["mass"];
    else
      mass = 0.0;
  }
}*/