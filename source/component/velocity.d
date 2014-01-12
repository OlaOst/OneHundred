module component.velocity;

import artemisd.all;
import gl3n.linalg;


final class Velocity : Component
{
  mixin TypeDecl;
  
  vec2 velocity;
  double rotation;
  
  alias velocity this;
  
  this(vec2 velocity, double rotation)
  {
    this.velocity = velocity;
    this.rotation = rotation;
  }
}
