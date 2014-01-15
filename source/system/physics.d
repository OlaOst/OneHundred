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

import integrator.integrator;
import integrator.state;
import integrator.states;

import timer;


final class Physics : EntityProcessingSystem
{
  mixin TypeDecl;
  World world;
  
  State[] previousStates;
  State[] currentStates;
  
  this(World world)
  {
    super(Aspect.getAspectForAll!(Position, Velocity, Mass, Input));
    this.world = world;
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
  
  double calculateTorque(State state, double time)
  {
    auto torque = 0.0;
    
    torque += state.rotation * -0.2; // damping torque
    
    auto input = state.entity.getComponent!Input;
    
    if (input && "rotateLeft" in input.isActive && input.isActive["rotateLeft"])
      torque += 1.0;
    if (input && "rotateRight" in input.isActive && input.isActive["rotateRight"])
      torque -= 1.0;
      
    // TODO: torque from collisions
    
    return torque;
  }
  
  vec2 calculateForce(State state, double time)
  {    
    auto force = vec2(0.0, 0.0);
    
    //force += state.position * -2.0; // spring force to center
    force += state.velocity * -0.05; // damping force
    
    auto input = state.entity.getComponent!Input;
    
    if (input && "accelerate" in input.isActive && input.isActive["accelerate"])
      force += vec2(cos(state.angle), sin(state.angle)) * 0.5;
    if (input && "decelerate" in input.isActive && input.isActive["decelerate"])
      force -= vec2(cos(state.angle), sin(state.angle)) * 0.5;
    
    if (auto gravity = state.entity.getComponent!Gravity)
    {
      vec2 gravityForce = gravity.getAccumulatedGravityForce(state.position, state.mass);
      gravityForce *= 0.5;
      force += gravityForce;
    }
    
    return force;
  }
}
