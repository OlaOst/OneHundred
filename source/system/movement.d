module system.movement;

import artemisd.all;
import gl3n.linalg;

import component.position;
import component.velocity;


final class Movement : EntityProcessingSystem
{
  mixin TypeDecl;
  
  World world;
  
  this(World world)
  {
    super(Aspect.getAspectForAll!(Position, Velocity));
    
    this.world = world;
  }
  
  override void process(Entity entity)
  {
    auto position = entity.getComponent!Position;
    auto velocity = entity.getComponent!Velocity;
    
    assert(position !is null);
    assert(velocity !is null);
    
    //position += velocity * world.getDelta();
    //position.angle += velocity.rotation * world.getDelta();
  }
}
