module integrator.states;

import std.range;

import integrator.integrator;
import integrator.state;


void integrateStates(ref State[] currentStates, 
                     ref State[] previousStates, 
                     double time, 
                     double timestep) @nogc
{
  previousStates = currentStates;

  foreach (ref state; currentStates)
  {
    state.integrate(time, timestep);
  }
}

void interpolateStates(ref State[] currentStates, 
                       ref State[] previousStates, 
                       double alpha) @nogc
{
  assert(currentStates.length == previousStates.length);
  
  for (size_t index = 0; index < currentStates.length; index++)
    currentStates[index].interpolate(previousStates[index], alpha);
    
  /*foreach (ref stateTuple; zip(currentStates, previousStates))
  {
    stateTuple[0].interpolate(stateTuple[1], alpha);
  }*/
}
