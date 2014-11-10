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
    if (auto spawn = ("spawner" in entity.values))
    {
      auto search = entityForIndex.values.find!(check => check.id == (*spawn).to!long);
      assert(!search.empty);
      component.spawner = search.front;
    }
    component.updateFromEntity(entity);
    return component;
  }

  override void updateValues()
  {
    int broadPhaseCount, narrowPhaseCount;
    StopWatch broadPhaseTimer, narrowPhaseTimer;

    broadPhaseTimer.start();
    foreach (collisionEntity; components)
      index.insert(collisionEntity);
    auto candidates = index.overlappingElements();
    broadPhaseTimer.stop();
    broadPhaseCount += candidates.length;

    narrowPhaseTimer.start();
    auto collisions = cartesianProduct(candidates, candidates)
                      .filter!(candidatePair => candidatePair[0].id < candidatePair[1].id)
                      .filter!(candidatePair => candidatePair[0].isOverlapping(candidatePair[1]))
                      .map!(collisionPair => Collision(collisionPair[0], collisionPair[1])).array;
    narrowPhaseTimer.stop();
    narrowPhaseCount += collisions.length;

    foreach (collision; collisions)
    {
      collision.first.isColliding = true;
      collision.other.isColliding = true;

      collision.first.overlappingColliders ~= collision.other;
      collision.other.overlappingColliders ~= collision.first;
    }

    debugText = format("collisionhandler checked %s/%s candidates\nbroadphase/narrowphase",
                       broadPhaseCount, narrowPhaseCount);
    debugText ~= format("\ncollisionhandler timings %s/%s milliseconds\nbroadphase/narrowphase",
                        broadPhaseTimer.peek.usecs*0.001, narrowPhaseTimer.peek.usecs*0.001);

    collisionEffectParticles ~= collisions.handleCollisions(this);

    index = new SpatialIndex!Collider();
  }

  override void updateEntities()
  {
    // collision responders deal with updating entity values
  }

  override void updateFromEntities()
  {
    foreach (uint index, Entity entity; entityForIndex)
    {
      components[index].updateFromEntity(entity);
    }
  }
}
