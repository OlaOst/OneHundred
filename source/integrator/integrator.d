module integrator.integrator;

import std.math;
import std.stdio;

import inmath.linalg;

import integrator.derivative;
import integrator.state;


Derivative evaluate(State initial, double time, double timestep, const Derivative derivative) 
pure nothrow @nogc
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
do
{
  State state = initial;
  
  state.position += derivative.velocity * timestep;
  state.velocity += derivative.force * timestep;
  state.angle = (state.angle + derivative.rotation * timestep).normalizedAngle;
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

void integrate(ref State state, double time, double timestep) pure nothrow @nogc
in
{
  assert(&state);
  assert(!time.isNaN);
  assert(!timestep.isNaN);
  assert(time >= 0.0);
  assert(timestep > 0.0);
}
out
{
  assert(&state);
}
do
{
  Derivative a = evaluate(state, time, timestep * 0.0, Derivative());
  Derivative b = evaluate(state, time, timestep * 0.5, a);
  Derivative c = evaluate(state, time, timestep * 0.5, b);
  Derivative d = evaluate(state, time, timestep * 1.0, c);
  
  //state.force = a.force;
  //state.torque = a.torque;
  
  // RK4 style
  vec3 positionChange = 1.0/6.0 * (a.velocity + 2.0 * (b.velocity + c.velocity) + d.velocity);
  vec3 velocityChange = 1.0/6.0 * (a.force + 2.0 * (b.force + c.force) + d.force);
  double angleChange = 1.0/6.0 * (a.rotation + 2.0 * (b.rotation + c.rotation) + d.rotation);
  double rotationChange = 1.0/6.0 * (a.torque + 2.0 * (b.torque + c.torque) + d.torque);
  
  // euler style
  //vec2 positionChange = a.velocity;
  //vec2 velocityChange = a.force;
  //double angleChange = a.rotation;
  //double rotationChange = a.torque;
  
  state.position += positionChange * timestep;
  state.velocity += velocityChange * timestep;
  state.angle = (state.angle + angleChange * timestep).normalizedAngle;
  state.rotation += rotationChange * timestep;
}
