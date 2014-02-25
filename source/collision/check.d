module collision.check;

import std.algorithm;
import std.range;
import std.stdio;

import artemisd.all;
import gl3n.linalg;

import component.drawable;
import component.mass;
import component.position;
import component.size;
import component.velocity;


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
      auto firstDrawable = entity.getComponent!Drawable;
      auto otherDrawable = other.entity.getComponent!Drawable;
      
      if (firstDrawable !is null && otherDrawable !is null)
      {
        auto firstVertices = firstDrawable.vertices;
        auto otherVertices = otherDrawable.vertices;
        
        return firstVertices.isOverlapping(otherVertices, velocity, other.velocity) ||
               otherVertices.isOverlapping(firstVertices, other.velocity, velocity);
      }
      else
      {
        return true;
      }
      
    }
    return false;
  }
  
  void updateFromEntity()
  {
    position = entity.getComponent!Position.position;
    velocity = entity.getComponent!Velocity.velocity;
    radius = entity.getComponent!Size.radius;
    mass = entity.getComponent!Mass;
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
