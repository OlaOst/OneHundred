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
  invariant
  {
    foreach (component; components)
      assert(component.angle < 20.0*PI && component.angle > -20.0*PI, "Physics component angle out of bounds: " ~ component.angle.to!string);
  }

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
  
  override void updateFromEntities()
  {
    // TODO: we have two separate places that handle forces and torques
    // 1. entity values
    // 2. forcecalculator
    // these should be combined into one stop shop for handling forces
    foreach (size_t index, Entity entity; entityForIndex)
    {
      components[index].position = entity.values["position"].myTo!vec2;
      components[index].velocity = entity.values["velocity"].myTo!vec2;
      components[index].force = vec2(0.0, 0.0);
      
      components[index].angle = "angle" in entity.values ? entity.values["angle"].to!double : 0.0;
      components[index].rotation = "rotation" in entity.values ? entity.values["rotation"].to!double : 0.0;
      components[index].torque = 0.0;
      
      if ("force" in entity.values)
        components[index].force = entity.values["force"].myTo!vec2;
      if ("torque" in entity.values)
        components[index].torque = entity.values["torque"].to!double;
        
      assert(components[index].force.magnitude < 1_000_000);
    }
  }
  
  override void updateValues()
  {
    StopWatch debugTimer;
    
    debugTimer.start;
    
    import std.stdio;
    import std.math;
    //writeln("running ", (timer.accumulator / timer.physicsTimeStep).floor, " physics integrations for this frame");
    
    while (timer.accumulator >= timer.physicsTimeStep)
    {
      if (timer.accumulator >= Timer.maxFrametime)
        writeln("maxframetime physicsstep, running integrateStates on ", components.length, " components, accumulator ", timer.accumulator);
      //integrateStates(currentStates, previousStates, timer.time, timer.physicsTimeStep);
      integrateStates(components, previousStates, timer.time, timer.physicsTimeStep);
      timer.accumulator -= timer.physicsTimeStep;
      timer.time += timer.physicsTimeStep;
    }
    //writeln("finished physics integration");
    
    //previousStates = currentStates;
    
    //interpolateStates(currentStates, previousStates, timer.accumulator / timer.physicsTimeStep);
    interpolateStates(components, previousStates, timer.accumulator / timer.physicsTimeStep);
    
    debugText = format("physics components: %s\nphysics timings: %s", components.length, debugTimer.peek.usecs*0.001);
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
