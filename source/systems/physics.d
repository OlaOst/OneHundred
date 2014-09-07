module systems.physics;

import std.algorithm;
import std.datetime;
import std.range;
    
import gl3n.linalg;

import components.input;
import components.relations.gravity;
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
    foreach (int index, Entity entity; entityForIndex)
    {
      entity.values["position"] = components[index].position.to!string;
      entity.values["velocity"] = components[index].velocity.to!string;
      entity.values["angle"] = components[index].angle.to!string;
    }
  }
  
  override void updateFromEntities()
  {
    foreach (int index, Entity entity; entityForIndex)
    {
      components[index].position = entity.values["position"].myTo!vec2;
      components[index].velocity = entity.values["velocity"].myTo!vec2;
      components[index].force = "force" in entity.values ? entity.values["force"].myTo!vec2 : vec2(0.0, 0.0);
      
      components[index].angle = "angle" in entity.values ? entity.values["angle"].to!double : 0.0;
      components[index].rotation = "rotation" in entity.values ? entity.values["rotation"].to!double : 0.0;
      components[index].torque = "torque" in entity.values ? entity.values["torque"].to!double : 0.0;
    }
  }
}
