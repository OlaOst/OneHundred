module component.size;

import artemisd.all;


final class Size : Component
{
  mixin TypeDecl;
  
  double radius;
  // TODO: AABB and/or vertex list describing convex hull?
  
  alias radius this;
  
  this(double radius)
  {
    this.radius = radius;
  }
}
