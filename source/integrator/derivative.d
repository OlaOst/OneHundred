module integrator.derivative;

import gl3n.linalg;


struct Derivative
{
  vec3 velocity = vec3(0.0, 0.0, 0.0);
  vec3 force = vec3(0.0, 0.0, 0.0);
  double rotation = 0.0;
  double torque = 0.0;
  
  invariant()
  {
    assert(velocity.isFinite);
    assert(force.isFinite);
    assert(!rotation.isNaN);
    assert(!torque.isNaN);
  }
}
