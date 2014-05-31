module systems.collisionhandler;

import std.algorithm;
import std.datetime;
import std.range;
import std.stdio;
    
import gl3n.linalg;

import collision.check;
import collision.responsehandler;
import components.collider;
import entity;
import spatialindex.spatialindex;
import system;


class CollisionHandler : System!CollisionEntity
{
  SpatialIndex!CollisionEntity index = new SpatialIndex!CollisionEntity();
  Entity[] collisionEffectParticles;
  
  override bool canAddEntity(Entity entity)
  {
    return entity.collider !is null;
  }
  
  override CollisionEntity makeComponent(Entity entity)
  {
    return CollisionEntity(entity);
  }
  
  override void update()
  {
    int broadPhaseCount, narrowPhaseCount;
    StopWatch broadPhaseTimer, narrowPhaseTimer;
    
    foreach (collisionEntity; components)
      index.insert(collisionEntity);
    
    Collision[] collisions;
    foreach (collisionEntity; components)
    {
      auto collider = collisionEntity.collider;
      collider.isColliding = false;
    
      broadPhaseTimer.start;
      auto candidates = index.find(collisionEntity.position, collisionEntity.radius);
      broadPhaseTimer.stop;
      broadPhaseCount += candidates.length;
      
      narrowPhaseTimer.start;
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
                                     
      narrowPhaseTimer.stop;
      narrowPhaseCount += collidingEntities.walkLength;
    }
    
    debugText = format("collisionhandler checked %s/%s candidates\nbroadphase/narrowphase", 
                       broadPhaseCount, 
                       narrowPhaseCount);
    debugText ~= format("\ncollisionhandler timings %s/%s milliseconds\nbroadphase/narrowphase", 
                        broadPhaseTimer.peek.usecs*0.001,
                        narrowPhaseTimer.peek.usecs*0.001);
                  
    collisionEffectParticles ~= collisions.handleCollisions;
    
    // reset index for the next update
    index = new SpatialIndex!CollisionEntity();
  }
  
  void updateFromEntities()
  {
    foreach (int index, Entity entity; entityForIndex)
      components[index].updateFromEntity();
  }
}
