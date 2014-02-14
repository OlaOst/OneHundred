module collision.check;

import std.algorithm;
import std.range;
import std.stdio;

import artemisd.all;
import gl3n.linalg;

import component.drawable;
import component.position;
import component.velocity;


struct CollisionEntity
{
  Entity entity;
  vec2 position;
  vec2 velocity;
  double radius;
  double mass;
  
  alias entity this;
  
  bool isOverlapping(CollisionEntity other)
  {
    if ((position - other.position).magnitude_squared < (radius + other.radius)^^2)
    {
      auto firstDrawable = entity.getComponent!Drawable;
      auto otherDrawable = other.entity.getComponent!Drawable;
      
      if (firstDrawable !is null && otherDrawable !is null)
      {
        // assume verts are in order
        // TODO: parse collision vertices when creating component 
        //       instead of digging them out of Drawable on every collision
        auto firstVertices = chain(firstDrawable.vertices[1..$].stride(3), 
                                   firstDrawable.vertices[2..$].stride(3)).
                             map!(vertex => vertex + position);
        auto otherVertices = chain(otherDrawable.vertices[1..$].stride(3),
                                   otherDrawable.vertices[2..$].stride(3)).
                             map!(vertex => vertex + other.position);
        
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
          
          if (firstMin > otherMax || firstMax < otherMin)
          {
            return false;
          }
          else
          {
            // TODO: also take angular velocity into account
            float velocityProjection = perpendicular.dot(other.velocity - velocity);
            if (velocityProjection < 0)
              firstMin += velocityProjection;
            else
              firstMax += velocityProjection;
            
            if (firstMin > otherMax || firstMax < otherMin)
              return false;
          }
        }
        
        foreach (vec2 line; zip(otherVertices[0..$-1], otherVertices[1..$]).
                            map!(vertexPair => vertexPair[1] - vertexPair[0]))
        {
          auto perpendicular = vec2(-line.y, line.x).normalized;
          
          auto firstProjections = firstVertices.map!(vertex => perpendicular.dot(vertex));
          auto otherProjections = otherVertices.map!(vertex => perpendicular.dot(vertex));
          
          auto firstMin = firstProjections.reduce!((a,b) => min(a,b));
          auto firstMax = firstProjections.reduce!((a,b) => max(a,b));
          auto otherMin = otherProjections.reduce!((a,b) => min(a,b));
          auto otherMax = otherProjections.reduce!((a,b) => max(a,b));
          
          //if (firstMin > otherMax || firstMax < otherMin)
          if (otherMin > firstMax || otherMax < firstMin)
          {
            return false;
          }
          else
          {
            // TODO: also take angular velocity into account
            float velocityProjection = perpendicular.dot(other.velocity - velocity);
            if (velocityProjection < 0)
              otherMin += velocityProjection;
            else
              otherMax += velocityProjection;
            
            if (otherMin > firstMax || otherMax < firstMin)
              return false;
          }
        }
        
        return true;
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
    // TODO: for now assume that radius and mass does not change
  }
}
