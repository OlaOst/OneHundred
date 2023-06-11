module integrator.arrayintegrator;

import std.algorithm;
import std.range;
import std.stdio;

import inmath.linalg;

import integrator.derivative;
import integrator.state;

/+
Derivative[] evaluate(State[] initials, 
                      double time, 
                      double timestep, 
                      const Derivative[] derivatives)
in
{
  initials.map!(state => assert(&state));
  assert(!time.isNaN);
  assert(!timestep.isNaN);
  derivatives.map!(derivative => assert(&derivative));
}
out(results)
{
  results.map!(derivative => assert(&derivative));
}
body
{
  State[] states = initials;
  
  zip(states, derivatives).map!(z => z[0].position += z[1].position * timestep);
  zip(states, derivatives).map!(z => z[0].velocity += z[1].velocity * timestep);
  zip(states, derivatives).map!(z => z[0].angle += z[1].angle * timestep);
  zip(states, derivatives).map!(z => z[0].rotation += z[1].rotation * timestep);
  
  states.map!(state => assert(&state));
  
  Derivative outputs[];
  
  outputs = states.map!(state => 
                        Derivative(state.velocity, 
                                   state.forceCalculator(state, time+timestep) * (1.0/state.mass), 
                                   state.rotation, 
                                   state.torqueCalculator(state, time+timestep) * (1.0/state.mass)
                                  )
                       ).array;
    
  return outputs;
}

void integrate(ref State[] states, double time, double timestep)
in
{
  states.map!(state => assert(&state));
  assert(!time.isNaN);
  assert(!timestep.isNaN);
}
out
{
  states.map!(state => assert(&state));
}
body
{
  auto blanks = Derivative().repeat.take(states.length).array;
  Derivative[] a = evaluate(states, time, timestep * 0.0, blanks);
  Derivative[] b = evaluate(states, time, timestep * 0.5, a);
  Derivative[] c = evaluate(states, time, timestep * 0.5, b);
  Derivative[] d = evaluate(states, time, timestep * 1.0, c);
  
  // RK4 style
  vec2[] positionChanges = zip(a, b, c, d).map!(d => 1.0/6.0 * 
                                                     (d[0].position +
                                                      2.0 * (d[1].position+d[2].position) +
                                                      d[3].position)).array;
  vec2[] velocityChanges = zip(a, b, c, d).map!(d => 1.0/6.0 * 
                                                     (d[0].velocity + 
                                                      2.0 * (d[1].velocity+d[2].velocity) +
                                                      d[3].velocity)).array;
  
  double[] angleChanges = zip(a, b, c, d).map!(d => 1.0/6.0 * 
                                                    (d[0].angle + 
                                                     2.0 * (d[1].angle + d[2].angle) + 
                                                     d[3].angle)).array;
  double[] rotationChanges = zip(a, b, c, d).map!(d => 1.0/6.0 * 
                                                       (d[0].rotation + 
                                                        2.0 * (d[1].rotation + d[2].rotation) + 
                                                        d[3].rotation)).array;
  
  // euler style
  //vec2 positionChange = a.position;
  //vec2 velocityChange = a.velocity;
  
  zip(states, positionChanges).map!(s => s[0].position += s[1] * timestep);
  zip(states, velocityChanges).map!(s => s[0].velocity += s[1] * timestep);
  zip(states, angleChanges).map!(s => s[0].angle += s[1] * timestep);
  zip(states, rotationChanges).map!(s => s[0].rotation += s[1] * timestep);
}
+/
