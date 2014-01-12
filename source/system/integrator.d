module system.integrator;

import std.stdio;

import gl3n.linalg;

import artemisd.all;


struct State
{
  vec2 position;
  vec2 velocity;
  float angle;
  float rotation;
  float mass;  
  vec2 delegate(State, float) forceCalculator;
  float delegate(State, float) torqueCalculator;
  Entity entity;
  
  invariant()
  {
    assert(position.ok);
    assert(velocity.ok);
    assert(!angle.isNaN);
    assert(!rotation.isNaN);
    assert(mass > 0.0, "Must have positive nonzero mass");    
    assert(forceCalculator !is null);
    assert(torqueCalculator !is null);
    assert(entity !is null);
  }
}

struct Derivative
{
  vec2 position = vec2(0.0, 0.0);
  vec2 velocity = vec2(0.0, 0.0);
  float angle = 0.0;
  float rotation = 0.0;
  
  invariant()
  {
    assert(position.ok);
    assert(velocity.ok);
    assert(!angle.isNaN);
    assert(!rotation.isNaN);
  }
}

Derivative evaluate(State initial, float time, float timestep, const Derivative derivative)
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
  output.rotation = state.torqueCalculator(state, time + timestep) * (1.0 / state.mass); // TODO: adjust rotation by shape tensor thingy instead of just mass which assumes perfectly regular shape
  
  return output;
}

void integrate(ref State state, float time, float timestep)
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
  
  float angleChange = 1.0/6.0 * (a.angle + 2.0 * (b.angle + c.angle) + d.angle);
  float rotationChange = 1.0/6.0 * (a.rotation + 2.0 * (b.rotation + c.rotation) + d.rotation);
  
  // euler style
  //vec2 positionChange = a.position;
  //vec2 velocityChange = a.velocity;
  
  state.position += positionChange * timestep;
  state.velocity += velocityChange * timestep;
  state.angle += angleChange * timestep;
  state.rotation += rotationChange * timestep;
}
