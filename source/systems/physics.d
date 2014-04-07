module systems.physics;

import std.algorithm;
import std.range;
    
import gl3n.linalg;

import component.input;
import component.relations.gravity;
import entity;
import forcecalculator;
import integrator.integrator;
import integrator.state;
import integrator.states;
import system;
import timer;


class Physics : System
{
  State[] previousStates;
  State[] currentStates;

  Timer timer;

  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.vectors && "mass" in entity.scalars;
  }
  
  override void addEntity(Entity entity)
  {
    if (canAddEntity(entity))
    {
      indexForEntity[entity] = currentStates.length;
      entityForIndex[currentStates.length] = entity;
      
      auto state = State(entity, &calculateForce, &calculateTorque);

      currentStates ~= state;
    }
  }
  
  void setTimer(Timer timer)
  {
    this.timer = timer;
  }
  
  override void update()
  {
    while (timer.accumulator >= timer.physicsTimeStep)
    {
      integrateStates(currentStates, previousStates, timer.time, timer.physicsTimeStep);
      timer.accumulator -= timer.physicsTimeStep;
      timer.time += timer.physicsTimeStep;
    }
    
    interpolateStates(currentStates, previousStates, timer.accumulator / timer.physicsTimeStep);
  }
  
  void updateEntities()
  {
    foreach (int index, Entity entity; entityForIndex)
    {
      entity.vectors["position"] = currentStates[index].position;
      entity.scalars["angle"] = currentStates[index].angle;
    }
  }
}
