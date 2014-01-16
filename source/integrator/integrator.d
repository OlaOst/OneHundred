module integrator.integrator;

import std.stdio;

import gl3n.linalg;

import integrator.derivative;
import integrator.state;


Derivative evaluate(State initial, double time, double timestep, const Derivative derivative)
in
{
  assert(&initial);
  assert(!time.isNaN);
  assert(!timestep.isNaN);
  assert(&derivative);
}
out(result)
{
  assert(&result);
}
body
{
  State state = initial;
  
  state.position += derivative.velocity * timestep;
  state.velocity += derivative.force * timestep;
  state.angle += derivative.rotation * timestep;
  state.rotation += derivative.torque * timestep;
  
  assert(&state);
  
  Derivative output;
  
  output.velocity = state.velocity;
  output.force = state.forceCalculator(state, time + timestep) * (1.0 / state.mass);
  output.rotation = state.rotation;
  // TODO: adjust rotation by shape tensor thingy instead of assuming perfectly regular shape
  output.torque = state.torqueCalculator(state, time + timestep) * (1.0 / state.mass); 
  
  return output;
}

void integrate(ref State state, double time, double timestep)
in
{
  assert(&state);  
  assert(!time.isNaN);
  assert(!timestep.isNaN);
}
out
{
  assert(&state);
}
body
{
  Derivative a = evaluate(state, time, timestep * 0.0, Derivative());
  Derivative b = evaluate(state, time, timestep * 0.5, a);
  Derivative c = evaluate(state, time, timestep * 0.5, b);
  Derivative d = evaluate(state, time, timestep * 1.0, c);
  
  // RK4 style
  vec2 positionChange = 1.0/6.0 * (a.velocity + 2.0 * (b.velocity + c.velocity) + d.velocity);
  vec2 velocityChange = 1.0/6.0 * (a.force + 2.0 * (b.force + c.force) + d.force);
  
  double angleChange = 1.0/6.0 * (a.rotation + 2.0 * (b.rotation + c.rotation) + d.rotation);
  double rotationChange = 1.0/6.0 * (a.torque + 2.0 * (b.torque + c.torque) + d.torque);
  
  // euler style
  //vec2 positionChange = a.position;
  //vec2 velocityChange = a.velocity;
  
  state.position += positionChange * timestep;
  state.velocity += velocityChange * timestep;
  state.angle += angleChange * timestep;
  state.rotation += rotationChange * timestep;
}
