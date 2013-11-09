module component.mass;

import artemisd.all;
import gl3n.linalg;


final class Mass : Component
{
  mixin TypeDecl;
  
  float mass;
  
  alias mass this;
  
  this(float mass)
  {
    this.mass = mass;
  }
}
