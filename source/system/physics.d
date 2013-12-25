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
    auto force = velocity * -0.01;
    auto torque = velocity.rotation * -1;
    
    // attract to center
    force += position * -0.1;
    
    // attraction force to other components
    if (relation !is null)
    {
      //debug writeln("setting force from " ~ relation.relations.length.to!string ~ " relations");
    
      vec2 gravityForce = relation.relations.filter!(relation => relation.getComponent!Position !is null && relation.getComponent!Mass !is null)
                                            .map!(relation => (relation.getComponent!Position - position).normalized * 
                                                              ((mass*relation.getComponent!Mass)/(relation.getComponent!Position - position).magnitude^^2))
                                            //.reduce!((relativePosition, forceSum) => forceSum + relativePosition);
                                            .reduce!"a+b";
    
      gravityForce *= 1.0 / relation.relations.length;
      
      force += gravityForce * 0.1;
      
      // collisions
      // TODO: make separate subsystem and components
      auto colliders = relation.relations.filter!(relation => relation.getComponent!Position !is null && relation.getComponent!Drawable !is null)
                               .filter!(relation => (relation.getComponent!Position - position).magnitude < (relation.getComponent!Drawable.size + entity.getComponent!Drawable.size));
                               
      foreach (collider; colliders)
      {
        auto relativePosition = collider.getComponent!Position - position;
        
        auto normalizedContactPoint = relativePosition.normalized();
        
        auto contactPoint = normalizedContactPoint * (entity.getComponent!Drawable.size^^2 / (entity.getComponent!Drawable.size + collider.getComponent!Drawable.size));
        
        if (velocity.velocity.dot(contactPoint.normalized) > 0.0)
        {
          velocity.velocity = velocity.velocity + (2.0 * -velocity.velocity.dot(contactPoint.normalized).abs * contactPoint.normalized);
        }
      }
    }
    
    //debug writeln("setting force to " ~ force.to!string);
    
    velocity += force * (1.0/mass) * world.getDelta();
    velocity.rotation += torque * (1.0/mass) * world.getDelta();
  }
}
