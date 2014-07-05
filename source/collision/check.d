module collision.check;

import std.algorithm;
import std.range;

import gl3n.linalg;

import components.collider;


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
