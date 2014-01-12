module component.position;

import artemisd.all;
import gl3n.linalg;


final class Position : Component
{
  mixin TypeDecl;
  
  vec2 position;
  float angle;
  
  alias position this;
  
  this(vec2 position, float angle)
  {
    this.position = position;
    this.angle = angle;
  }
}
