module component.velocity;

import artemisd.all;
import gl3n.linalg;


final class Velocity : Component
{
  mixin TypeDecl;
  
  vec2 velocity;
  float rotation;
  
  alias velocity this;
  
  this(vec2 velocity, float rotation)
  {
    this.velocity = velocity;
    this.rotation = rotation;
  }
  
  this(float x, float y, float rotation)
  {
    this(vec2(x, y), rotation);
  }
}
