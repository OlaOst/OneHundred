module collision.check;

import std.algorithm;
import std.range;

import gl3n.linalg;

import component.collider;
import entity;


struct CollisionEntity
{
  Entity entity;
  vec2 position;
  vec2 velocity;
  double radius;
  double mass;
  alias entity this;
  
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
}

bool isOverlapping(vec2[] firstVertices, vec2[] otherVertices, 
                   vec2 firstVelocity, vec2 otherVelocity)
{
  foreach (vec2 line; zip(firstVertices[0..$-1], firstVertices[1..$]).
                      map!(vertexPair => vertexPair[1] - vertexPair[0]))
  {
    auto perpendicular = vec2(-line.y, line.x).normalized;
    
    auto firstProjections = firstVertices.map!(vertex => perpendicular.dot(vertex));
    auto otherProjections = otherVertices.map!(vertex => perpendicular.dot(vertex));
    
    auto firstMin = firstProjections.reduce!((a,b) => min(a,b));
    auto firstMax = firstProjections.reduce!((a,b) => max(a,b));
    auto otherMin = otherProjections.reduce!((a,b) => min(a,b));
    auto otherMax = otherProjections.reduce!((a,b) => max(a,b));
    
    if (firstMin < otherMax && firstMax > otherMin)
    {
      // TODO: also take angular velocity into account
      float velocityProjection = perpendicular.dot(otherVelocity - firstVelocity);
      if (velocityProjection < 0)
        firstMin += velocityProjection;
      else
        firstMax += velocityProjection;
      
      if (firstMin > otherMax || firstMax < otherMin)
        return false;
    }
    else
      return false;
  }
  return true;
}
