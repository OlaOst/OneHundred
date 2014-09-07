module systems.collisionhandler;

import std.algorithm;
import std.conv;
import std.datetime;
import std.range;
import std.stdio;

import gl3n.linalg;

import collision.responsehandler;
import components.collider;
import converters;
import entity;
import spatialindex.spatialindex;
import system;


class CollisionHandler : System!Collider
{
  SpatialIndex!Collider index = new SpatialIndex!Collider();
  Entity[] collisionEffectParticles;
  
  override bool canAddEntity(Entity entity)
  {
    return ("collider" in entity.values) !is null && ("position" in entity.values) !is null;
  }
  
  override Collider makeComponent(Entity entity)
  {
    vec2[] verts = [vec2(0.0, 0.0)];
    if (("collider.vertices" in entity.values) !is null)
      verts = entity.values["collider.vertices"].myTo!(vec2[]);
      
    auto component = Collider(verts, entity.values["collider"].to!ColliderType, entity.id);
    
    if ("spawner" in entity.values)
    {
      auto search = entityForIndex.values.find!(check => check.id == entity.values["spawner"].to!long);

      assert(!search.empty);
      
      if (!search.empty)
        component.spawner = search.front;
    }
    
    component.updateFromEntity(entity);
    
    return component;
  }
  
  override void updateValues()
  {
    int broadPhaseCount, narrowPhaseCount;
    StopWatch broadPhaseTimer, narrowPhaseTimer;
    
    foreach (collisionEntity; components)
      index.insert(collisionEntity);
    
    Collision[] collisions;
    foreach (ref collider; components)
    {
      auto collisionEntity = getEntity(collider);
      assert(collisionEntity !is null);
      
      collider.isColliding = false;
    
      broadPhaseTimer.start;
      auto candidates = index.find(collider.position, collider.radius);
      broadPhaseTimer.stop;
      broadPhaseCount += candidates.length;
      
      narrowPhaseTimer.start;
      auto collidingColliders = 
        candidates.filter!(candidate => candidate.id != collisionEntity.id && 
                                        candidate.isOverlapping(collider))
                  .filter!(collidingEntity => !(collisions.any!(collision => 
                                                          (collision.first.id == collisionEntity.id && 
                                                           collision.other.id == collidingEntity.id) || 
                                                          (collision.other.id == collisionEntity.id && 
                                                           collision.first.id == collidingEntity.id))));

      collider.overlappingColliders = collidingColliders.array;
      collisions ~= collidingColliders.map!(collidingCollider => 
                                     Collision(collider, collidingCollider)).array;
                                     
      narrowPhaseTimer.stop;
      narrowPhaseCount += collidingColliders.walkLength;
    }
    
    debugText = format("collisionhandler checked %s/%s candidates\nbroadphase/narrowphase", 
                       broadPhaseCount, 
                       narrowPhaseCount);
    debugText ~= format("\ncollisionhandler timings %s/%s milliseconds\nbroadphase/narrowphase", 
                        broadPhaseTimer.peek.usecs*0.001,
                        narrowPhaseTimer.peek.usecs*0.001);
      
    // TODO: just signal that effect particles should be added here
    // let some other system handle the particles
    collisionEffectParticles ~= collisions.handleCollisions(this);
    
    // reset index for the next update
    index = new SpatialIndex!Collider();
  }
  
  override void updateEntities()
  {
    // collision responders deal with updating entity values
    /*foreach (int index, Entity entity; entityForIndex)
    {
      
    }*/
  }
  
  override void updateFromEntities()
  {
    foreach (int index, Entity entity; entityForIndex)
    {
      components[index].updateFromEntity(entity);
    }
  }
}
