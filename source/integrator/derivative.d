module integrator.derivative;

import gl3n.linalg;


struct Derivative
{
  vec2 velocity = vec2(0.0, 0.0);
  vec2 force = vec2(0.0, 0.0);
  double rotation = 0.0;
  double torque = 0.0;
  
  invariant()
  {
    assert(velocity.ok);
    assert(force.ok);
    assert(!rotation.isNaN);
    assert(!torque.isNaN);
  }
}
