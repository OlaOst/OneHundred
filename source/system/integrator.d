module integrator;

import gl3n.linalg;


struct State
{
  vec2 position;
  vec2 velocity;
}

struct Derivative
{
  vec2 position = vec2(0.0, 0.0);
  vec2 velocity = vec2(0.0, 0.0);
}

Derivative evaluate(const State initial, float time, float timestep, const Derivative derivative)
in
{
  assert(initial.position.ok);
  assert(initial.velocity.ok);
  
  assert(!time.isNaN);
  assert(!timestep.isNaN);
  
  assert(derivative.position.ok);
  assert(derivative.velocity.ok);    
}
out(result)
{
  assert(result.position.ok);
  assert(result.velocity.ok);
}
body
{
  State state;
  
  state.position = initial.position + derivative.position * timestep;
  state.velocity = initial.velocity + derivative.velocity * timestep;
  
  Derivative output;
  
  output.position = state.velocity;
  output.velocity = calculateForce(state, time + timestep);
  
  return output;
}

vec2 calculateForce(const State state, float time)
in
{
  assert(state.position.ok);
  assert(state.velocity.ok);
}
out(result)
{
  assert(result.ok);
}
body
{
  //debug writeln("calculateForce returning " ~ (state.position * -0.2).to!string);
  return state.position * -22.2;
}

void integrate(ref State state, float time, float timestep)
in
{
  assert(state.position.ok);
  assert(state.velocity.ok);
  
  assert(!time.isNaN);
  assert(!timestep.isNaN);
}
out
{
  assert(state.position.ok);
  assert(state.velocity.ok);
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
