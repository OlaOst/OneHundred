module system.integrator;

import gl3n.linalg;

import component.relations.gravity;


struct State
{
  vec2 position;
  vec2 velocity;
  float mass;  
  vec2 delegate(State, float) forceCalculator;
  Gravity relation; // TODO: more generic class
  
  invariant()
  {
    assert(position.ok);
    assert(velocity.ok);
    assert(mass > 0.0, "Must have positive nonzero mass");    
    assert(forceCalculator !is null);
    assert(relation !is null);
  }
}

struct Derivative
{
  vec2 position = vec2(0.0, 0.0);
  vec2 velocity = vec2(0.0, 0.0);
  
  invariant()
  {
    assert(position.ok);
    assert(velocity.ok);
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
  
  assert(&state);
  
  Derivative output;
  
  output.position = state.velocity;
  output.velocity = state.forceCalculator(state, time + timestep) * (1.0 / state.mass);
  
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
  
  // euler style
  //vec2 positionChange = a.position;
  //vec2 velocityChange = a.velocity;
  
  state.position += positionChange * timestep;
  state.velocity += velocityChange * timestep;
}
