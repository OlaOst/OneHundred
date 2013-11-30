module system.physics;

import artemisd.all;
import gl3n.linalg;

import component.mass;
import component.position;
import component.relation;
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
    auto relation = entity.getComponent!Relation;
    
    // TODO: workaround for buggy getAspectForAll
    //if (position is null || velocity is null || mass is null)
      //return;
      
    assert(position !is null);
    assert(velocity !is null);
    assert(mass !is null);
    
    // damping force and torque
    auto force = position * -1;
    auto torque = velocity.rotation * -1;
    
    // attraction force to other components
    if (relation !is null)
    {
      foreach (relationEntity; relation.relations)
      {
        auto relationPosition = relationEntity.getComponent!Position;
        
        assert(relationPosition !is null);
        
        auto relativePosition = relationPosition - position;
        
        force -= relativePosition * 0.1;
      }
    }
    
    //import std.stdio;
    //import std.conv;
    //debug writeln("setting force to " ~ force.to!string);
    
    velocity += force * (1.0/mass) * world.getDelta();
    velocity.rotation += torque * (1.0/mass) * world.getDelta();
  }
}
