module integrator.integrator;

import std.math;
import std.stdio;

import gl3n.linalg;

import integrator.derivative;
import integrator.state;


Derivative evaluate(State initial, double time, double timestep, const Derivative derivative) pure nothrow @nogc
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
  
  // normalize angle
  
  // TODO: idiot case in case the integrator flips out and gives gigantic angles. make better
  if (state.angle > 1_000_000_000 || state.angle < -1_000_000_000)
      state.angle = 0.0;
      
  if (state.angle > PI || state.angle < -PI)
  {
    //writeln("normalizing state angle from ", state.angle, " to " , (state.angle - (state.angle/PI).floor * PI));
    state.angle -= (state.angle/PI).floor * PI;
  }
  
  assert(&state);
  
  Derivative output;
  
  output.velocity = state.velocity;
  output.force = state.forceCalculator(state, time + timestep) * (1.0 / state.mass);
  output.rotation = state.rotation;
  // TODO: adjust rotation by shape tensor thingy instead of assuming perfectly regular shape
  output.torque = state.torqueCalculator(state, time + timestep) * (1.0 / state.mass); 
  
  //writeln("integrator.evaluate for ", initial.entity.id, " end, force is ", output.force);
  
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
  
  // TODO: ...is this right?
  //state.force = 1.0/6.0 * (a.force + 2.0 * (b.force + c.force) + d.force);
  //state.torque = 1.0/6.0 * (a.torque + 2.0 * (b.torque + c.torque) + d.torque);
  state.force = a.force;
  state.torque = a.torque;
  
  // euler style
  //vec2 positionChange = a.position;
  //vec2 velocityChange = a.velocity;
  
  state.position += positionChange * timestep;
  state.velocity += velocityChange * timestep;
  state.angle += angleChange * timestep;
  state.rotation += rotationChange * timestep;
  
  // normalize angle
  // TODO: idiot case in case the integrator flips out and gives gigantic angles. make better
  if (state.angle > 1_000_000_000 || state.angle < -1_000_000_000)
      state.angle = 0.0;
      
  if (state.angle > PI || state.angle < -PI)
  {
    //writeln("normalizing state angle from ", state.angle, " to " , (state.angle - (state.angle/PI).floor * PI));
    state.angle -= (state.angle/PI).floor * PI;
  }
}
