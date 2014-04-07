module systems.collisionhandler;

import std.algorithm;
import std.datetime;
import std.range;
import std.stdio;
    
import gl3n.linalg;

import collision.check;
import collision.response;
import component.collider;
import entity;
import spatialindex.spatialindex;
import system;


class CollisionHandler : System
{
  SpatialIndex!CollisionEntity index = new SpatialIndex!CollisionEntity();
  CollisionEntity[] collisionEntities;
  
  override bool canAddEntity(Entity entity)
  {
    return entity.collider !is null;
  }
  
  override void addEntity(Entity entity)
  {
    if (canAddEntity(entity))
    {
      indexForEntity[entity] = collisionEntities.length;
      entityForIndex[collisionEntities.length] = entity;
      collisionEntities ~= CollisionEntity(entity);
    }
  }
  
  override void update()
  {
    debug int broadPhaseCount, midPhaseCount, narrowPhaseCount;
    debug StopWatch broadPhaseTimer, narrowPhaseTimer;
    
    foreach (collisionEntity; collisionEntities)
      index.insert(collisionEntity);
    
    Collision[] collisions;
    foreach (collisionEntity; collisionEntities)
    {
      auto collider = collisionEntity.collider;
      collider.isColliding = false;
    
      debug broadPhaseTimer.start;
      auto candidates = index.find(collisionEntity.position, collisionEntity.radius);
      debug broadPhaseTimer.stop;
      debug broadPhaseCount += candidates.length;
      
      debug midPhaseCount += candidates.filter!(candidate => 
                               (collisionEntity.position - candidate.position).magnitude_squared < 
                               (collisionEntity.radius + candidate.radius)^^2).walkLength;
      
      debug narrowPhaseTimer.start;
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
                                     
      debug narrowPhaseTimer.stop;
      debug narrowPhaseCount += collidingEntities.walkLength;
    }
    
    /*debug writeln("collisionhandler checked ", collisionEntities.length, "/",
                                               broadPhaseCount, "/", 
                                               midPhaseCount, "/", 
                                               narrowPhaseCount, 
                  " candidates in total/broadphase/midphase/narrowphase");
    debug writeln("collisionhandler timings ", broadPhaseTimer.peek.usecs*0.001, "/", 
                                               narrowPhaseTimer.peek.usecs*0.001, 
                  " candidates in broadphase/narrowphase");*/
                  
    handleCollisions(collisions);
    
    // reset index for the next update
    index = new SpatialIndex!CollisionEntity();
  }
  
  void updateFromEntities()
  {
    foreach (int index, Entity entity; entityForIndex)
      collisionEntities[index].updateFromEntity();
  }
}
