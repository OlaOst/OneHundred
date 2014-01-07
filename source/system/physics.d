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

import integrator;


final class Physics : EntityProcessingSystem
{
  mixin TypeDecl;
  
  World world;
  
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
    
    // TODO: workaround for buggy getAspectForAll
    //if (position is null || velocity is null || mass is null)
      //return;
      
    assert(position !is null);
    assert(velocity !is null);
    assert(mass !is null);
    
    // damping force and torque
    //auto force = velocity * -0.002;
    //auto torque = 0.0; //velocity.rotation * -0.01;
    
    // attract to center
    //force += position * -0.01;
    
    // attraction force to other components
    /*if (relation !is null)
    {
      //debug writeln("setting force from " ~ relation.relations.length.to!string ~ " relations");
    
      vec2 gravityForce = relation.relations.filter!(relation => relation.getComponent!Position !is null && relation.getComponent!Mass !is null)
                                            .map!(relation => (relation.getComponent!Position - position).normalized * 
                                                              ((mass*relation.getComponent!Mass)/(relation.getComponent!Position - position).magnitude^^2))
                                            //.reduce!((relativePosition, forceSum) => forceSum + relativePosition);
                                            .reduce!"a+b";
    
      //gravityForce *= 1.0 / relation.relations.length;
      gravityForce *= 0.05;
      
      force += gravityForce * 1.5;
    }*/
    
    //debug writeln("setting force to " ~ force.to!string);
    
    //velocity += force * (1.0/mass) * world.getDelta();
    //velocity.rotation += torque * (1.0/mass) * world.getDelta();
    
    State state;
    state.position = position.position;
    state.velocity = velocity.velocity;
    state.mass = mass.mass;
    
    integrate(state, 0.0, 1.0/60.0);

    position.position = state.position;
    velocity.velocity = state.velocity;
  }
}
