module system.physics;

import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
    
import artemisd.all;
import gl3n.linalg;

import component.drawable;
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
    super(Aspect.getAspectForAll!(Position, Velocity, Mass));
    
    this.world = world;
  }

  override void process(Entity entity)
  {
    auto position = entity.getComponent!Position;
    auto velocity = entity.getComponent!Velocity;
    auto mass = entity.getComponent!Mass;
    auto relation = entity.getComponent!Gravity;
      
    assert(position !is null);
    assert(velocity !is null);
    assert(mass !is null);
  
    auto state = State(position, velocity, mass, &calculateForce, relation);
    
    integrate(state, 0.0, 1.0/60.0);
    
    position.position = state.position;
    velocity.velocity = state.velocity;
  }
  
  vec2 calculateForce(State state, float time)
  {    
    auto force = vec2(0.0, 0.0);
    
    //force += state.position * -2.0; // spring force to center
    force += state.velocity * -0.05; // damping force
    
    vec2 getGravityForce(vec2 firstPosition, vec2 otherPosition, float firstMass, float otherMass)
    {
      return (firstPosition-otherPosition).normalized * 
             ((firstMass*otherMass) / (firstPosition-otherPosition).magnitude^^2);
    }
    
    vec2 gravityForce = 
      state.relation.relations.filter!(relation => relation.getComponent!Position && 
                                                   relation.getComponent!Mass)
                              .map!(relation => getGravityForce(relation.getComponent!Position, 
                                                                state.position, 
                                                                relation.getComponent!Mass, 
                                                                state.mass))
                              .reduce!"a+b";

    gravityForce *= 0.5;
    
    force += gravityForce;
    
    return force;
  }
}
