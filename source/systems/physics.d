module systems.physics;

import std.algorithm;
import std.datetime;
import std.range;
    
import gl3n.linalg;

import components.input;
import converters;
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
    return "position" in entity.values && "mass" in entity.values;
  }
  
  override State makeComponent(Entity entity)
  {
    return State(entity, &calculateForce, &calculateTorque);
  }
  
  override void updateValues()
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
  
  override void updateEntities()
  {
    foreach (size_t index, Entity entity; entityForIndex)
    {
      entity.values["position"] = components[index].position.to!string;
      entity.values["velocity"] = components[index].velocity.to!string;
      entity.values["angle"] = components[index].angle.to!string;
    }
  }
  
  override void updateFromEntities()
  {
    foreach (size_t index, Entity entity; entityForIndex)
    {
      components[index].position = entity.values["position"].myTo!vec2;
      components[index].velocity = entity.values["velocity"].myTo!vec2;
      
      components[index].force = vec2(0.0, 0.0);
      components[index].angle = 0.0;
      components[index].rotation = 0.0;
      components[index].torque = 0.0;
      
      if ("force" in entity.values)
        components[index].force = entity.values["force"].myTo!vec2;
      if ("angle" in entity.values)
        components[index].angle = entity.values["angle"].to!double;
      if ("rotation" in entity.values)
        components[index].rotation = entity.values["rotation"].to!double;
      if ("torque" in entity.values)
        components[index].torque = entity.values["torque"].to!double;
    }
  }
}
