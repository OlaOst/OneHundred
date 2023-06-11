module systems.collisionhandler;

import std;

import inmath.aabb;
import inmath.linalg;

import collision.responsehandler;
import components.collider;
import entity;
import spatialindex.rtree;
import system;
import systems.collisionhandlerdebughelper;


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

    import std.datetime.stopwatch;
    auto broadPhaseTimer = StopWatch(AutoStart.yes);
    components.each!(component => index.insert(component));
    auto candidates = index.overlappingElements();
    index.populateLeveledBoxes(boxes = null);
    broadPhaseTimer.stop();

    auto filterCandidates = function bool (Collider left, Collider right) => (left.id < right.id &&
      !left.colliderIdsToIgnore.canFind(right.id) && !right.colliderIdsToIgnore.canFind(left.id) &&
      left.isOverlapping(right));
    
    auto narrowPhaseTimer = StopWatch(AutoStart.yes);
    auto collisions = candidates.filter!(pair => filterCandidates(pair[0], pair[1]))
                                .map!(pair => Collision(pair[0], pair[1])).array;
    narrowPhaseTimer.stop();
    
    debugText = getDebugText(broadPhaseTimer, narrowPhaseTimer, 
                             candidates.length, collisions.length);
    
    components.each!(component => component.overlappingColliders.length = 0);

    foreach (collision; collisions)
    {
      collision.first.isColliding = collision.other.isColliding = true;
      collision.first.overlappingColliders ~= collision.other;
      collision.other.overlappingColliders ~= collision.first;
    }
    
    collisionEffectParticles ~= collisions.handleCollisions(this);
  }
  
  // collision responders deal with updating entity values
  void updateEntities() {}

  void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
      components[index].updateFromEntity(entity);
  }
}
