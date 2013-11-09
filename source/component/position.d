module component.position;

import artemisd.all;
import gl3n.linalg;


final class Position : Component
{
  mixin TypeDecl;
  
  vec2 position;
  
  alias position this;
  
  this(vec2 position)
  {
    this.position = position;
  }
  
  this(float x, float y)
  {
    this.position = vec2(x, y);
  }
}
