module system.physics;

import artemisd.all;
import gl3n.linalg;

import component.position;
import component.velocity;
import component.mass;


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
    
    auto force = position.position * -1;
    
    velocity += force * (1.0/mass) * world.getDelta();
  }
}
