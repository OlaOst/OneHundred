module integrator.states;

import std.range;

import integrator.integrator;
import integrator.state;


void integrateStates(ref State[] currentStates, ref State[] previousStates, double time, double timestep)
{
  previousStates = currentStates;

  foreach (ref state; currentStates)
  {
    state.integrate(time, timestep);
    state.updateComponents();
  }
}

void interpolateStates(ref State[] currentStates, ref State[] previousStates, double alpha)
{
  foreach (ref stateTuple; zip(currentStates, previousStates))
  {
    stateTuple[0].interpolate(stateTuple[1], alpha);
    stateTuple[0].updateComponents();
  }
}
