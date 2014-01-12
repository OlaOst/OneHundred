module component.mass;

import artemisd.all;
import gl3n.linalg;


final class Mass : Component
{
  mixin TypeDecl;
  
  double mass;
  
  alias mass this;
  
  this(double mass)
  {
    this.mass = mass;
  }
}
