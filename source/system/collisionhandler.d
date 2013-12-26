module system.collisionhandler;

import std.algorithm;
import std.conv;
import std.math;
import std.stdio;
    
import artemisd.all;
import gl3n.linalg;

import component.mass;
import component.position;
import component.relations.collider;
import component.size;
import component.velocity;


final class CollisionHandler : EntityProcessingSystem
{
  mixin TypeDecl;
  
  World world;
  
  this(World world)
  {
    super(Aspect.getAspectForAll!(Collider));
    
    this.world = world;
  }
  
  override void process(Entity entity)
  {
    auto position = entity.getComponent!Position;
    auto velocity = entity.getComponent!Velocity;
    auto size = entity.getComponent!Size;
    auto mass = entity.getComponent!Mass;
    auto collider = entity.getComponent!Collider;
    
    auto radius = (size !is null) ? size.radius : 0.0;
      
    assert(position !is null);
    assert(collider !is null);
    
    // attraction force to other components
    // TODO: collision response should be handled elsewhere, this class should just generate collision events
    if (collider !is null)
    {
      auto collisions = collider.relations.filter!(candidate => candidate.getComponent!Position !is null && candidate.getComponent!Size !is null)
                                .filter!(candidate => (candidate.getComponent!Position - position).magnitude < (candidate.getComponent!Size.radius + radius));
                               
      foreach (collision; collisions)
      {
        auto collisionPosition = collision.getComponent!Position;
        auto collisionSize = collision.getComponent!Size;
        
        assert(collisionPosition !is null);
        assert(collisionSize !is null);
        
        auto relativePosition = collisionPosition - position;
        
        auto normalizedContactPoint = relativePosition.normalized();
        
        auto contactPoint = normalizedContactPoint * (radius^^2 / (radius + collisionSize.radius));
        
        if (velocity.velocity.dot(contactPoint.normalized) > 0.0)
        {
          velocity += (2.0 * -velocity.velocity.dot(contactPoint.normalized).abs * contactPoint.normalized) * 0.9;
        }
      }
    }
  }
}
