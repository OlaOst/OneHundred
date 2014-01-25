module system.collisionhandler;

import std.algorithm;
import std.array;
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
import spatialindex.spatialindex;


final class CollisionHandler : EntityProcessingSystem
{
  mixin TypeDecl;
  
  class CollisionEntity
  {
    Entity entity;
    vec2 position;
    vec2 velocity;
    double radius;
    double mass;
    
    alias entity this;
    
    this(Entity entity, vec2 position, vec2 velocity, double radius, double mass)
    {
      this.entity = entity;
      this.position = position;
      this.velocity = velocity;
      this.radius = radius;
      this.mass = mass;
    }
    
    override int opCmp(Object o)
    {
      auto other = cast(CollisionEntity) o;
      
      return entity.getId - other.entity.getId;
    }
    
    bool isOverlapping(CollisionEntity other)
    {
      return (position - other.position).magnitude < (radius + other.radius);
    }
  }
  
  World world;
  SpatialIndex!CollisionEntity index;
  CollisionEntity[] collisionEntities;
  
  this(World world)
  {
    super(Aspect.getAspectForAll!(Collider));
    
    this.world = world;
    
    index = new SpatialIndex!CollisionEntity();
  }
  
  override void process(Entity entity)
  {
    auto position = entity.getComponent!Position;
    auto velocity = entity.getComponent!Velocity;
    auto size = entity.getComponent!Size;
    auto mass = entity.getComponent!Mass;
    //auto collider = entity.getComponent!Collider;
    
    //assert(position !is null);
    //assert(collider !is null);
    
    //collider.position = position;
    //collider.radius = size.radius;
    
    auto collisionEntity = new CollisionEntity(entity, position, velocity, size.radius, mass);
    index.insert(collisionEntity);
    collisionEntities ~= collisionEntity;
  }
  
  void update()
  {
    struct Collision
    {
      CollisionEntity first;
      CollisionEntity other;
    }
    
    Collision[] collisions;
      
    foreach (collisionEntity; collisionEntities)
    {
      auto candidates = index.find(collisionEntity.position, collisionEntity.radius);
      
      auto collidingEntities = candidates.filter!(candidate => candidate != collisionEntity && candidate.isOverlapping(collisionEntity))
                                         .filter!(collidingEntity => !(collisions.any!(collision => (collision.first == collisionEntity && collision.other == collidingEntity) || 
                                                                                                    (collision.other == collisionEntity && collision.first == collidingEntity))));
      
      collisions ~= collidingEntities.map!(collidingEntity => Collision(collisionEntity, collidingEntity)).array;
    }
    
    //debug writeln("Collisionhandler handling ", collisions.length, " collision");
    
    // TODO: filter collisions so there are no collisions where Collision(first,other) == Collision(other,first)
    foreach (collision; collisions)
    {
      //auto normalizedContactPoint = relativePosition.normalized();
      //auto contactPoint = normalizedContactPoint * (collision.first.radius^^2 / (collision.first.radius + collision.other.radius));
      
      // find momentums
      //auto firstMomentum = collision.first.velocity * collision.first.mass;
      //auto otherMomentum = collision.other.velocity * collision.other.mass;
      
      auto firstVelocity = collision.first.velocity * ((collision.first.mass - collision.other.mass) / (collision.first.mass + collision.other.mass)) +
                           collision.other.velocity * ((2 * collision.other.mass)                    / (collision.first.mass + collision.other.mass));
      auto otherVelocity = collision.other.velocity * ((collision.other.mass - collision.first.mass) / (collision.first.mass + collision.other.mass)) +
                           collision.first.velocity * ((2 * collision.first.mass)                    / (collision.first.mass + collision.other.mass));
      
      auto momentumBefore = collision.first.velocity * collision.first.mass + collision.other.velocity * collision.other.mass;
      auto momentumAfter = firstVelocity * collision.first.mass + otherVelocity * collision.other.mass;
      assert(approxEqual(momentumBefore.magnitude, momentumAfter.magnitude), "Momentum not conserved in collision: went from " ~ momentumBefore.to!string ~ " to " ~ momentumAfter.to!string);
      
      //debug writeln("changing vel from ", collision.first.velocity, " to ", firstVelocity);
      
      auto firstVel = collision.first.entity.getComponent!Velocity;
      firstVel = firstVelocity;
      auto otherVel = collision.other.entity.getComponent!Velocity;
      otherVel = otherVelocity;
      
      // change positions to ensure colliders does not overlap
      auto firstPos = collision.first.entity.getComponent!Position;
      auto otherPos = collision.other.entity.getComponent!Position;
      
      auto contactPoint = (collision.other.position - collision.first.position);
      
      firstPos += (contactPoint - contactPoint.normalized() * (collision.first.radius+collision.other.radius)) * 0.5;
      otherPos -= (contactPoint - contactPoint.normalized() * (collision.first.radius+collision.other.radius)) * 0.5;
    }
    
    // reset entity list and index so we are ready for the next update
    collisionEntities.length = 0;
    index = new SpatialIndex!CollisionEntity();
    /*
    auto radius = (size !is null) ? size.radius : 0.0;
    
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
    */
  }
}
