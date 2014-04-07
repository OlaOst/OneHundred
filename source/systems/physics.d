module systems.physics;

import std.algorithm;
import std.math;
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
  invariant()
  {
    //assert(positions.length == masses.length);
    
    // ensure there is a one-to-one mapping for indices in the arrays and the indexForEntity mapping
    /*foreach (const Entity entity, int index; indexForEntity)
    {
      assert(index >= 0 && index <= positions.length);
    }*/
  }
  
  State[] previousStates;
  State[] currentStates;
  
  //vec2[] positions;
  //float[] masses;
  
  Timer timer;
  
  this()
  {
  }

  /*override void process(Entity entity)
  {
    if (entity.getComponent!Mass !is null)
    {
      auto state = State(entity, &calculateForce, &calculateTorque);
      currentStates ~= state;
    }
  }*/
  
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
      /*state.position = entity.vectors["position"];
      state.mass = entity.scalars["mass"];
      
      if ("velocity" in entity.vectors)
      {
        state.velocity = entity.vectors["velocity"];
        state.momentum = state.velocity * state.mass;
      }*/
      
      //if ("angle" in entity.scalars)
        //state.angle = entity.scalars["angle"];
      
      //state.forceCalculator = &calculateForce;
      //state.torqueCalculator = &calculateTorque;

      currentStates ~= state;
      
      /+ stuff in State
      // primaries
      vec2 position;
      vec2 momentum;
      double angle;
      //double rotationalMomentum;
      
      // secondaries
      vec2 velocity;
      double rotation;
      
      //constants
      double mass;
      
      vec2 function(State, double time) forceCalculator;
      double function(State, double time) torqueCalculator;
      Entity entity;
      +/
    }
  }
  
  void setTimer(Timer timer)
  {
    this.timer = timer;
  }
  
  override void update()
  {
    //import std.stdio;
    //writeln("physics update, positions are ", currentStates.map!(state => state.position).array);
    
    while (timer.accumulator >= timer.physicsTimeStep)
    {
      integrateStates(currentStates, previousStates, timer.time, timer.physicsTimeStep);
      timer.accumulator -= timer.physicsTimeStep;
      timer.time += timer.physicsTimeStep;
    }
    
    interpolateStates(currentStates, previousStates, timer.accumulator / timer.physicsTimeStep);
    //currentStates.length = 0;
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
