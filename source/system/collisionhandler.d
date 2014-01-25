module system.collisionhandler;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.stdio;
    
import artemisd.all;
import gl3n.linalg;

import collisionresponse;
import component.mass;
import component.position;
import component.relations.collider;
import component.size;
import component.velocity;
import spatialindex.spatialindex;


final class CollisionHandler : EntityProcessingSystem
{
  mixin TypeDecl;
  
  SpatialIndex!CollisionEntity index = new SpatialIndex!CollisionEntity();
  CollisionEntity[] collisionEntities;
  
  this()
  {
    super(Aspect.getAspectForAll!(Collider));
  }
  
  override void process(Entity entity)
  {
    auto position = entity.getComponent!Position;
    auto velocity = entity.getComponent!Velocity;
    auto size = entity.getComponent!Size;
    auto mass = entity.getComponent!Mass;
    
    auto collisionEntity = CollisionEntity(entity, position, velocity, size.radius, mass);
    index.insert(collisionEntity);
    collisionEntities ~= collisionEntity;
  }
  
  void update()
  {
    Collision[] collisions;
    foreach (collisionEntity; collisionEntities)
    {
      auto candidates = index.find(collisionEntity.position, collisionEntity.radius);
      
      auto collidingEntities = 
        candidates.filter!(candidate => candidate != collisionEntity && 
                                        candidate.isOverlapping(collisionEntity))
                  .filter!(collidingEntity => !(collisions.any!(collision => 
                                                          (collision.first == collisionEntity && 
                                                           collision.other == collidingEntity) || 
                                                          (collision.other == collisionEntity && 
                                                           collision.first == collidingEntity))));
      
      collisions ~= collidingEntities.map!(collidingEntity => 
                                     Collision(collisionEntity, collidingEntity)).array;
    }
    
    handleCollisions(collisions);
    
    // reset entity list and index so we are ready for the next update
    collisionEntities.length = 0;
    index = new SpatialIndex!CollisionEntity();
  }
}
