module systems.physics;

import std.algorithm;
import std.datetime;
import std.range;
    
import gl3n.linalg;

import components.input;
import components.relations.gravity;
import entity;
import forcecalculator;
import integrator.integrator;
import integrator.state;
import integrator.states;
import system;
import timer;


class Physics : System!State
{
  State[] previousStates;
  //State[] currentStates;

  Timer timer;

  void setTimer(Timer timer)
  {
    this.timer = timer;
  }
  
  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.vectors && "mass" in entity.scalars;
  }
  
  override State makeComponent(Entity entity)
  {
    return State(entity, &calculateForce, &calculateTorque);
  }
  
  override void update()
  {
    StopWatch debugTimer;
    
    debugTimer.start;
    
    while (timer.accumulator >= timer.physicsTimeStep)
    {
      //integrateStates(currentStates, previousStates, timer.time, timer.physicsTimeStep);
      integrateStates(components, previousStates, timer.time, timer.physicsTimeStep);
      timer.accumulator -= timer.physicsTimeStep;
      timer.time += timer.physicsTimeStep;
    }
    
    //previousStates = currentStates;
    
    //interpolateStates(currentStates, previousStates, timer.accumulator / timer.physicsTimeStep);
    interpolateStates(components, previousStates, timer.accumulator / timer.physicsTimeStep);
    
    debugText = format("physics timings: %s", debugTimer.peek.usecs*0.001);
  }
  
  void updateEntities()
  {
    foreach (size_t index, Entity entity; entityForIndex)
    {
      //entity.vectors["position"] = currentStates[index].position;
      //entity.vectors["velocity"] = currentStates[index].velocity;
      //entity.scalars["angle"] = currentStates[index].angle;
      entity.vectors["position"] = components[index].position;
      entity.vectors["velocity"] = components[index].velocity;
      entity.scalars["angle"] = components[index].angle;
    }
  }
  
  void updateFromEntities()
  {
    foreach (size_t index, Entity entity; entityForIndex)
    {
      //currentStates[index].velocity = entity.vectors["velocity"];
      components[index].velocity = entity.vectors["velocity"];
    }
  }
}
