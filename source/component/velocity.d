module component.velocity;

import artemisd.all;
import gl3n.linalg;


final class Velocity : Component
{
  mixin TypeDecl;
  
  vec2 velocity;
  
  alias velocity this;
  
  this(vec2 velocity)
  {
    this.velocity = velocity;
  }
  
  this(float x, float y)
  {
    this.velocity = vec2(x, y);
  }
}
