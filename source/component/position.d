module component.position;

import artemisd.all;
import gl3n.linalg;


final class Position : Component
{
  mixin TypeDecl;
  
  vec2 position;
  double angle;
  
  alias position this;
  
  this(vec2 position, double angle)
  {
    this.position = position;
    this.angle = angle;
  }
}
