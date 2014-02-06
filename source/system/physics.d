module system.physics;

import std.algorithm;
import std.math;
import std.range;
    
import artemisd.all;
import gl3n.linalg;

import component.input;
import component.mass;
import component.position;
import component.relations.gravity;
import component.velocity;
import forcecalculator;
import integrator.integrator;
import integrator.state;
import integrator.states;
import timer;


final class Physics : EntityProcessingSystem
{
  mixin TypeDecl;
  
  State[] previousStates;
  State[] currentStates;
  
  this()
  {
    super(Aspect.getAspectForAll!(Position, Velocity, Mass, Input));
  }

  override void process(Entity entity)
  {
    auto state = State(entity, &calculateForce, &calculateTorque);
    currentStates ~= state;
  }
  
  void update(Timer timer)
  {
    while (timer.accumulator >= timer.physicsTimeStep)
    {
      integrateStates(currentStates, previousStates, timer.time, timer.physicsTimeStep);
      timer.accumulator -= timer.physicsTimeStep;
      timer.time += timer.physicsTimeStep;
    }
    
    interpolateStates(currentStates, previousStates, timer.accumulator / timer.physicsTimeStep);
    currentStates.length = 0;
  }
}
