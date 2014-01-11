module component.input;

import artemisd.all;


final class Input : Component
{
  mixin TypeDecl;
  
  bool accelerate = false;
  bool decelerate = false;
  bool rotateLeft = false;
  bool rotateRight = false;
  
  this()
  {
    
  }
}
