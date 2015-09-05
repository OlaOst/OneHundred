module systems.collisionhandler;

import std.algorithm;
import std.conv;
import std.datetime;
import std.range;
import std.regex;
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

  bool canAddEntity(Entity entity)
  {
    return entity.has("collider") && entity.has("position");
  }

  Collider makeComponent(Entity entity)
  {
    vec3[] verts = entity.get!(vec3[])("collider.vertices", [vec3(0.0, 0.0, 0.0)]);
    auto component = new Collider(verts, entity.get!ColliderType("collider"), entity.id);
    
    if (entity.has("collisionfilter"))
    {
      auto collisionFilter = regex(entity.get!string("collisionfilter"));
      component.colliderIdsToIgnore = entityForIndex.byValue.filter!(checkEntity => checkEntity.get!string("fullName").matchFirst(collisionFilter))
                                                            .map!(checkEntity => checkEntity.id).array.dup;
    }
    
    entityForIndex.byValue.filter!(checkEntity => checkEntity.has("collisionfilter"))
                          .filter!(checkEntity => entity.get!string("fullName").matchFirst(checkEntity.get!string("collisionfilter")))
                          .each!(checkEntity => getComponent(checkEntity).colliderIdsToIgnore ~= entity.id);
    
    component.updateFromEntity(entity);
    return component;
  }

  void updateValues()
  {
    int broadPhaseCount, narrowPhaseCount;
    
    auto broadPhaseTimer = StopWatch(AutoStart.yes);
    components.each!(collisionEntity => index.insert(collisionEntity));
    auto candidates = index.overlappingElements();
    broadPhaseTimer.stop();
    broadPhaseCount += candidates.length;

    auto narrowPhaseTimer = StopWatch(AutoStart.yes);
    auto collisions = cartesianProduct(candidates, candidates)
                .filter!(candidatePair => filterCandidates(candidatePair[0], candidatePair[1]))
                .map!(collisionPair => Collision(collisionPair[0], collisionPair[1])).array;
    narrowPhaseTimer.stop();
    narrowPhaseCount += collisions.length;

    components.each!(component => component.overlappingColliders.length = 0);

    foreach (collision; collisions)
    {
      collision.first.isColliding = true;
      collision.other.isColliding = true;
      collision.first.overlappingColliders ~= collision.other;
      collision.other.overlappingColliders ~= collision.first;
    }

    debugText = format("collisionhandler checked %s/%s candidates\nbroadphase/narrowphase",
                       broadPhaseCount, narrowPhaseCount) ~
                format("\ncollisionhandler timings %s/%s milliseconds\nbroadphase/narrowphase",
                       broadPhaseTimer.peek.usecs*0.001, narrowPhaseTimer.peek.usecs*0.001);

    collisionEffectParticles ~= collisions.handleCollisions(this);

    index = new SpatialIndex!Collider();
  }

  bool filterCandidates(Collider left, Collider right)
  {
    return left.id < right.id && 
           !left.colliderIdsToIgnore.canFind(right.id) &&
           !right.colliderIdsToIgnore.canFind(left.id) &&
           left.isOverlapping(right);
  }
  
  // collision responders deal with updating entity values
  void updateEntities() {}

  void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
      components[index].updateFromEntity(entity);
  }
}
