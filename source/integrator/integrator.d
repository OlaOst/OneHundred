module integrator.integrator;

import std.stdio;

import gl3n.linalg;

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
  
  state.position += derivative.position * timestep;
  state.velocity += derivative.velocity * timestep;
  state.angle += derivative.angle * timestep;
  state.rotation += derivative.rotation * timestep;
  
  assert(&state);
  
  Derivative output;
  
  output.position = state.velocity;
  output.velocity = state.forceCalculator(state, time + timestep) * (1.0 / state.mass);
  output.angle = state.rotation;
  // TODO: adjust rotation by shape tensor thingy instead of assuming perfectly regular shape
  output.rotation = state.torqueCalculator(state, time + timestep) * (1.0 / state.mass); 
  
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
  vec2 positionChange = 1.0/6.0 * (a.position + 2.0 * (b.position + c.position) + d.position);
  vec2 velocityChange = 1.0/6.0 * (a.velocity + 2.0 * (b.velocity + c.velocity) + d.velocity);
  
  double angleChange = 1.0/6.0 * (a.angle + 2.0 * (b.angle + c.angle) + d.angle);
  double rotationChange = 1.0/6.0 * (a.rotation + 2.0 * (b.rotation + c.rotation) + d.rotation);
  
  // euler style
  //vec2 positionChange = a.position;
  //vec2 velocityChange = a.velocity;
  
  state.position += positionChange * timestep;
  state.velocity += velocityChange * timestep;
  state.angle += angleChange * timestep;
  state.rotation += rotationChange * timestep;
}
