module component.size;

import artemisd.all;


final class Size : Component
{
  mixin TypeDecl;
  
  float radius;
  // TODO: AABB and/or vertex list describing convex hull?
  
  alias radius this;
  
  this(float radius)
  {
    this.radius = radius;
  }
}
