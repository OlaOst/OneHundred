module system.collisionhandler;

import std.algorithm;
import std.array;
import std.conv;
import std.datetime;
import std.math;
import std.range;
import std.stdio;
    
import artemisd.all;
import gl3n.linalg;

import collision.check;
import collision.response;
import component.collider;
import component.mass;
import component.position;
import component.size;
import component.velocity;
import spatialindex.spatialindex;


final class CollisionHandler : EntityProcessingSystem
{
  mixin TypeDecl;
  SpatialIndex!CollisionEntity index = new SpatialIndex!CollisionEntity();
  CollisionEntity[] collisionEntities;
  World world;
  
  this(World world)
  {
    super(Aspect.getAspectForAll!(Collider));
    this.world = world;
  }
  
  override void process(Entity entity)
  {
    auto collisionEntity = CollisionEntity(entity);
    index.insert(collisionEntity);
    collisionEntities ~= collisionEntity;
  }
  
  void update()
  {
    debug int broadPhaseCount, midPhaseCount, narrowPhaseCount;
    debug StopWatch broadPhaseTimer, narrowPhaseTimer;
    
    Collision[] collisions;
    foreach (collisionEntity; collisionEntities)
    {
      auto collider = collisionEntity.getComponent!Collider;
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
    
    /*debug writeln("collisionhandler checked ", broadPhaseCount, "/", 
                                               midPhaseCount, "/", 
                                               narrowPhaseCount, 
                  " candidates in broadphase/midphase/narrowphase");
    debug writeln("collisionhandler timings ", broadPhaseTimer.peek.usecs*0.001, "/", 
                                               narrowPhaseTimer.peek.usecs*0.001, 
                  " candidates in broadphase/narrowphase");*/
                  
    handleCollisions(world, collisions);
    
    // reset entity list and index so we are ready for the next update
    collisionEntities.length = 0;
    index = new SpatialIndex!CollisionEntity();
  }
}
