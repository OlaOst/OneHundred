module system.physics;

import std.algorithm;
import std.conv;
import std.math;
import std.range;
import std.stdio;
    
import artemisd.all;
import gl3n.linalg;

import component.drawable;
import component.input;
import component.mass;
import component.position;
import component.relations.gravity;
import component.velocity;

import integrator.integrator;
import integrator.state;


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
    
    //integrate(state, time, deltaTime);
    //state.updateComponents();
  }
  
  void update(double time, double timestep)
  {
    previousStates = currentStates;
  
    //integrate(states, time, timestep);
        
    foreach (ref state; currentStates)
    {
      state.integrate(time, timestep);
      state.updateComponents();
    }
    
    //states.map!(state => integrate(state, time, timestep));
    //states.map!(state => state.updateComponents());
  }
  
  void interpolateStates(double alpha)
  {
    foreach (stateTuple; zip(currentStates, previousStates))
    {
      State interpolated = stateTuple[0];
      
      interpolated.position = stateTuple[0].position * alpha + stateTuple[1].position * (1.0-alpha);
      interpolated.velocity = stateTuple[0].velocity * alpha + stateTuple[1].velocity * (1.0-alpha);
      interpolated.angle = stateTuple[0].angle * alpha + stateTuple[1].angle * (1.0-alpha);
      interpolated.rotation = stateTuple[0].rotation * alpha + stateTuple[1].rotation * (1.0-alpha);
      
      interpolated.updateComponents();
    }
  }
  
  void resetStates()
  {
    currentStates.length = 0;
  }
  
  double calculateTorque(State state, double time)
  {
    auto torque = 0.0;
    
    torque += state.rotation * -0.2; // damping torque
    
    auto input = state.entity.getComponent!Input;
    
    if (input && input.rotateLeft)
      torque += 1.0;
    if (input && input.rotateRight)
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
    
    if (input && input.accelerate)
      force += vec2(cos(state.angle), sin(state.angle)) * 0.5;
    if (input && input.decelerate)
      force -= vec2(cos(state.angle), sin(state.angle)) * 0.5;
      
    vec2 getGravityForce(vec2 firstPosition, vec2 otherPosition, double firstMass, double otherMass)
    {
      return (firstPosition-otherPosition).normalized * 
             ((firstMass*otherMass) / (firstPosition-otherPosition).magnitude^^2);
    }
    
    auto gravity = state.entity.getComponent!Gravity;
    
    if (gravity && gravity.relations.length > 0)
    {
      vec2 gravityForce = 
        gravity.relations.filter!(relation => relation.getComponent!Position && 
                                              relation.getComponent!Mass)
                         .map!(relation => getGravityForce(relation.getComponent!Position, 
                                                           state.position, 
                                                           relation.getComponent!Mass, 
                                                           state.mass))
                         .reduce!"a+b";

      gravityForce *= 0.5;
      
      force += gravityForce;
    }
    
    return force;
  }
}
