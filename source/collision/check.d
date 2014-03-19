module collision.check;

import std.algorithm;
import std.range;
import std.stdio;

import artemisd.all;
import gl3n.linalg;

import component.collider;
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
  in
  {
    //assert(entity.getComponent!Position !is null);
    //assert(entity.getComponent!Velocity !is null);
    //assert(entity.getComponent!Size !is null);
    //assert(entity.getComponent!Mass !is null);
  }
  body
  {
    this.entity = entity;
    updateFromEntity();
  }
  
  bool isOverlapping(CollisionEntity other)
  {
    if ((position - other.position).magnitude_squared < (radius + other.radius)^^2)
    {
      auto firstCollider = entity.getComponent!Collider;
      auto otherCollider = other.entity.getComponent!Collider;
      
      if (firstCollider !is null && otherCollider !is null)
      {
        auto firstVertices = firstCollider.vertices;
        auto otherVertices = otherCollider.vertices;
        
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
    if (entity.getComponent!Position !is null)
      position = entity.getComponent!Position.position;
    else
      position = vec2(0.0, 0.0);
    if (entity.getComponent!Velocity !is null)
      velocity = entity.getComponent!Velocity.velocity;
    else
      velocity = vec2(0.0, 0.0);
    if (entity.getComponent!Size !is null)
      radius = entity.getComponent!Size.radius;
    else
      radius = 0.0;
    if (entity.getComponent!Mass !is null)
      mass = entity.getComponent!Mass;
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
    
    writeln("firstminmax ", firstMin, " ", firstMax, ", otherminmax ", otherMin, " ", otherMax);
    writeln("firstmin < otherMax: ", firstMin < otherMax, ", firstmax > otherMin: ", firstMax > otherMin); 
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
  writeln("SAT returning true");
  return true;
}
