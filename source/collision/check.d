module collision.check;

import std.algorithm;
import std.range;

import inmath.linalg;

import components.collider;


bool isOverlapping(vec3[] firstVertices, vec3[] otherVertices, 
                   vec3 firstVelocity, vec3 otherVelocity)
{
  foreach (vec3 line; zip(firstVertices[0..$-1], firstVertices[1..$]).
                      map!(vertexPair => vertexPair[1] - vertexPair[0]))
  {
    auto perpendicular = vec2(-line.y, line.x).normalized;
    
    auto firstProjections = firstVertices.map!(vertex => perpendicular.dot(vertex.xy));
    auto otherProjections = otherVertices.map!(vertex => perpendicular.dot(vertex.xy));
    
    auto firstMin = firstProjections.reduce!((a,b) => min(a,b));
    auto firstMax = firstProjections.reduce!((a,b) => max(a,b));
    auto otherMin = otherProjections.reduce!((a,b) => min(a,b));
    auto otherMax = otherProjections.reduce!((a,b) => max(a,b));
    
    if (firstMin < otherMax && firstMax > otherMin)
    {
      // TODO: also take angular velocity into account
      double velocityProjection = perpendicular.dot(otherVelocity.xy - firstVelocity.xy);
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
