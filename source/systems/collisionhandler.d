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
    return entity.has("collider") && entity.has("position");
  }

  override Collider makeComponent(Entity entity)
  {
    vec3[] verts = [vec3(0.0, 0.0, 0.0)];
    if (entity.has("collider.vertices"))
      verts = entity.get!(vec3[])("collider.vertices");

    auto component = new Collider(verts, entity.get!ColliderType("collider"), entity.id);
    if (entity.has("spawner"))
    {
      auto spawn = entity.get!long("spawner");
      auto search = entityForIndex.values.find!(check => check.id == spawn);
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

    foreach (component; components)
      component.overlappingColliders.length = 0;

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

  // collision responders deal with updating entity values
  override void updateEntities() {}

  override void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      components[index].updateFromEntity(entity);
    }
  }
}
