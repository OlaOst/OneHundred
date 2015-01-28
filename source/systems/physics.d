module systems.physics;

import std.algorithm;
import std.datetime;
import std.range;
    
import gl3n.linalg;

import accumulatortimer;
import components.input;
import converters;
import entity;
import forcecalculator;
import integrator.integrator;
import integrator.state;
import integrator.states;
import system;


class Physics : System!State
{
  alias components currentStates;
  State[] previousStates;
  AccumulatorTimer timer;

  this()
  {
    timer = new AccumulatorTimer(0.25, 1.0/60.0);
  }
  
  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.values && "mass" in entity.values;
  }
  
  override State makeComponent(Entity entity)
  {
    return State(entity, &calculateForce, &calculateTorque);
  }
  
  override void updateFromEntities()
  {
    // TODO: we have two separate places that handle forces and torques
    // 1. entity values
    // 2. forcecalculator
    // these should be combined into one stop shop for handling forces
    foreach (size_t index, Entity entity; entityForIndex)
    {
      components[index].position = entity.get!vec2("position");
      components[index].velocity = entity.get!vec2("velocity");
      components[index].force = entity.get!vec2("force");
      components[index].angle = entity.get!double("angle");
      components[index].rotation = entity.get!double("rotation");
      components[index].torque = entity.get!double("torque");
    }
  }
  
  override void updateValues()
  {
    //StopWatch debugTimer;
    
    //debugTimer.start;
    timer.incrementAccumulator();
    
    previousStates = currentStates;
    double time = timer.currentTime;
    while (timer.accumulator >= timer.timeStep)
    {
      integrateStates(currentStates, previousStates, time, timer.timeStep);
      timer.accumulator -= timer.timeStep;
      time += timer.timeStep;
    }
    interpolateStates(currentStates, previousStates, timer.accumulator / timer.timeStep);
    
    //debugText = format("physics components: %s\nphysics timings: %s", components.length, 
    //                                                                  debugTimer.peek.usecs*0.001);
  }
  
  override void updateEntities()
  {
    foreach (size_t index, Entity entity; entityForIndex)
    {
      entity.values["position"] = components[index].position.to!string;
      entity.values["velocity"] = components[index].velocity.to!string;
      entity.values["angle"] = components[index].angle.to!string;
      entity.values["rotation"] = components[index].rotation.to!string;
        
      // reset force and torque for next update
      entity.values["force"] = vec2(0.0, 0.0).to!string;
      entity.values["torque"] = 0.0.to!string;
      
      // keep old values, from forceCalculator
      entity.values["previousForce"] = components[index].force.to!string;
      entity.values["previousTorque"] = components[index].torque.to!string;
    }
  }
}
