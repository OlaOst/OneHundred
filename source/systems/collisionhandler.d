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


class CollisionHandler : System!CollisionEntity
{
  SpatialIndex!CollisionEntity index = new SpatialIndex!CollisionEntity();
  string debugText;
  
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
    debug int broadPhaseCount, midPhaseCount, narrowPhaseCount;
    debug StopWatch broadPhaseTimer, narrowPhaseTimer;
    
    foreach (collisionEntity; components)
      index.insert(collisionEntity);
    
    Collision[] collisions;
    foreach (collisionEntity; components)
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
    
    debugText = format("collisionhandler checked %s/%s/%s/%s candidates\ntotal/broadphase/midphase/narrowphase", 
                       components.length,
                       broadPhaseCount, 
                       midPhaseCount,
                       narrowPhaseCount);
    debugText ~= format("\ncollisionhandler timings %s/%s milliseconds\nbroadphase/narrowphase", 
                        broadPhaseTimer.peek.usecs*0.001,
                        narrowPhaseTimer.peek.usecs*0.001);
                  
    handleCollisions(collisions);
    
    // reset index for the next update
    index = new SpatialIndex!CollisionEntity();
  }
  
  void updateFromEntities()
  {
    foreach (int index, Entity entity; entityForIndex)
      components[index].updateFromEntity();
  }
}
