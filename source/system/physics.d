module system.physics;

import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
    
import artemisd.all;
import gl3n.linalg;

import component.drawable;
import component.input;
import component.mass;
import component.position;
import component.relations.gravity;
import component.velocity;

import system.integrator;


final class Physics : EntityProcessingSystem
{
  mixin TypeDecl;
  
  World world;
  
  State[] states;
  
  this(World world)
  {
    super(Aspect.getAspectForAll!(Position, Velocity, Mass, Input));
    
    this.world = world;
  }

  override void process(Entity entity)
  {
    auto position = entity.getComponent!Position;
    auto velocity = entity.getComponent!Velocity;
    auto mass = entity.getComponent!Mass;
    //auto relation = entity.getComponent!Gravity;
      
    assert(position !is null);
    assert(velocity !is null);
    assert(mass !is null);
  
    auto state = State(position, velocity, position.angle, velocity.rotation, mass, &calculateForce, &calculateTorque, entity);
    
    integrate(state, 0.0, 1.0/60.0);
    
    position.position = state.position;
    velocity.velocity = state.velocity;
    position.angle = state.angle;
    velocity.rotation = state.rotation;
  }
  
  float calculateTorque(State state, float time)
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
  
  vec2 calculateForce(State state, float time)
  {    
    auto force = vec2(0.0, 0.0);
    
    //force += state.position * -2.0; // spring force to center
    force += state.velocity * -0.05; // damping force
    
    auto input = state.entity.getComponent!Input;
    
    if (input && input.accelerate)
      force += vec2(cos(state.angle), sin(state.angle)) * 0.5;
    if (input && input.decelerate)
      force -= vec2(cos(state.angle), sin(state.angle)) * 0.5;
      
    vec2 getGravityForce(vec2 firstPosition, vec2 otherPosition, float firstMass, float otherMass)
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
