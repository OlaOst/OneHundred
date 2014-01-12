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
    // TODO: collision response should be handled elsewhere
    //       this class should just generate collision events
    if (collider !is null)
    {
      struct Circle
      {
        vec2 position;
        double radius;
      }
      
      bool isOverlapping(Entity first, Entity other)
      {
        auto firstPosition = first.getComponent!Position;
        auto firstRadius = first.getComponent!Size.radius;
        auto otherPosition = other.getComponent!Position;
        auto otherRadius = other.getComponent!Size.radius;
        
        return (firstPosition - otherPosition).magnitude < (firstRadius + otherRadius);
      }
      
      auto entityCircle = Circle(position, radius);
      
      auto collisions = collider.relations.filter!(candidate => candidate.getComponent!Position && 
                                                                candidate.getComponent!Size)
                                          .filter!(candidate => isOverlapping(candidate, entity));
                               
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
          velocity += (2.0 * -velocity.velocity.dot(contactPoint.normalized).abs * 
                       contactPoint.normalized) * 0.99;
        }
      }
    }
  }
}
