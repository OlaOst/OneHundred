module systems.collisionhandler;

import std.algorithm;
import std.datetime;
import std.range;
import std.regex;

import gl3n.aabb;
import gl3n.linalg;

import collision.responsehandler;
import components.collider;
import entity;
import spatialindex.hilberthash;
import spatialindex.quadtree;
import spatialindex.rtree;
import system;


class CollisionHandler : System!Collider
{
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
      auto collisionFilter = entity.get!string("collisionfilter");
      
      component.colliderIdsToIgnore = 
        entityForIndex.byValue.filter!(checkEntity => checkEntity.get!string("fullName")
                                                                 .matchFirst(collisionFilter))
                              .map!(checkEntity => checkEntity.id).array.dup;
    }
    
    entityForIndex.byValue
      .filter!(checkEntity => checkEntity.has("collisionfilter"))
      .filter!(checkEntity => entity.get!string("fullName")
                                    .matchFirst(checkEntity.get!string("collisionfilter")))
      .each!(checkEntity => getComponent(checkEntity).colliderIdsToIgnore ~= entity.id);
    
    component.updateFromEntity(entity);
    return component;
  }
  
  AABB[][int] boxes;
  
  void updateValues()
  {
    auto index = new RTree!Collider;
    //auto index = new QuadTree!Collider;
    //auto index = new HilbertHash!Collider;

    auto broadPhaseTimer = StopWatch(AutoStart.yes);
    components.each!(component => index.insert(component));
    auto candidates = index.overlappingElements();

    boxes = null;
    index.populateLeveledBoxes(boxes);
    
    broadPhaseTimer.stop();

    auto narrowPhaseTimer = StopWatch(AutoStart.yes);
    auto collisions = candidates//cartesianProduct(candidates, candidates)
                .filter!(candidatePair => filterCandidates(candidatePair[0], candidatePair[1]))
                .map!(collisionPair => Collision(collisionPair[0], collisionPair[1])).array;
    narrowPhaseTimer.stop();
    
    components.each!(component => component.overlappingColliders.length = 0);

    foreach (collision; collisions)
    {
      collision.first.isColliding = collision.other.isColliding = true;
      collision.first.overlappingColliders ~= collision.other;
      collision.other.overlappingColliders ~= collision.first;
    }

    static enum double dampingFactor = 0.9;
    static double dampenedBroadPhaseTimer = 0.0;
    static double dampenedNarrowPhaseTimer = 0.0;
    dampenedBroadPhaseTimer = dampenedBroadPhaseTimer * dampingFactor + broadPhaseTimer.peek.usecs * (1.0 - dampingFactor);
    dampenedNarrowPhaseTimer = dampenedNarrowPhaseTimer * dampingFactor + narrowPhaseTimer.peek.usecs * (1.0 - dampingFactor);
    debugText = format("collisionhandler checked %s/%s candidates\nbroadphase/narrowphase",
                       candidates.length, collisions.length) ~
                format("\ncollisionhandler timings %s/%s milliseconds\nbroadphase/narrowphase",
                       //broadPhaseTimer.peek.usecs*0.001, narrowPhaseTimer.peek.usecs*0.001);
                       cast(int)(dampenedBroadPhaseTimer*0.001), cast(int)(dampenedNarrowPhaseTimer*0.001));

    collisionEffectParticles ~= collisions.handleCollisions(this);
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
