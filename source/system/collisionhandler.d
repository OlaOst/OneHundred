module system.collisionhandler;

import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
    
import artemisd.all;
import gl3n.linalg;

import component.mass;
import component.position;
import component.relations.collision;
import component.size;
import component.velocity;


final class CollisionHandler : EntityProcessingSystem
{
  mixin TypeDecl;
  
  World world;
  
  this(World world)
  {
    super(Aspect.getAspectForAll!(Position, Collision));
    
    this.world = world;
  }
  
  override void process(Entity entity)
  {
    auto position = entity.getComponent!Position;
    auto velocity = entity.getComponent!Velocity;
    auto size = entity.getComponent!Size;
    auto mass = entity.getComponent!Mass;
    auto collision = entity.getComponent!Collision;
    
    auto radius = (size !is null) ? size.radius : 0.0;
      
    assert(position !is null);
    assert(collision !is null);
    
    // attraction force to other components
    // TODO: collision response should be handled elsewhere, this class should just generate collision events
    if (collision !is null)
    {
      auto colliders = collision.relations.filter!(collider => collider.getComponent!Position !is null && collider.getComponent!Size !is null)
                                .filter!(collider => (collider.getComponent!Position - position).magnitude < (collider.getComponent!Size.radius + radius));
                               
      foreach (collider; colliders)
      {
        auto relativePosition = collider.getComponent!Position - position;
        
        auto normalizedContactPoint = relativePosition.normalized();
        
        auto contactPoint = normalizedContactPoint * (radius^^2 / (radius + collider.getComponent!Size.radius));
        
        if (velocity.velocity.dot(contactPoint.normalized) > 0.0)
        {
          velocity.velocity = velocity.velocity + (2.0 * -velocity.velocity.dot(contactPoint.normalized).abs * contactPoint.normalized);
        }
      }
    }
  }
}
