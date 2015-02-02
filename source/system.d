module system;

import std.algorithm;
import std.array;
import std.conv;
import std.datetime;
import std.range;
import std.string;

import entity;
import systemdebug;


abstract class System(ComponentType) : SystemDebug
{
  invariant()
  {
    assert(indexForEntity.length == entityForIndex.length,
           "indexForEntity/entityForIndex length mismatch");
    assert(indexForEntity.length == components.length,
           "indexForEntity/components length mismatch");
    // ensure there is a one-to-one mapping between indices and entities
    foreach (size_t index, const Entity entity; entityForIndex)
    {
      assert(index in entityForIndex && entity in indexForEntity);
      assert(entityForIndex[index] == entity && indexForEntity[entity] == index);
      assert(index >= 0 && index < components.length);
    }
  }
  
  ComponentType getComponent(Entity entity)
  {
    assert(entity in indexForEntity);
    return components[indexForEntity[entity]];
  }
  
  Entity getEntity(ComponentType component)
  {
    auto index = components.countUntil(component);
    return (index < 0) ? null : entityForIndex[index];
  }
  
  void addEntity(Entity entity)
  {
    if (canAddEntity(entity))
    {
      auto component = makeComponent(entity);
      indexForEntity[entity] = components.length;
      entityForIndex[components.length] = entity;
      components ~= component;
    }
  }
  
  void removeEntity(Entity entity)
  {
    if (entity !in indexForEntity) return;
    auto index = indexForEntity[entity];
    auto indexToMove = components.length - 1;
    assert(indexToMove in entityForIndex);
    // swap last component with the one to be deleted, then pop off the last component
    components[index] = components[indexToMove];
    components.popBack();
    // remember to update entity/index mappings
    auto movedEntity = entityForIndex[indexToMove];
    indexForEntity[movedEntity] = index;
    entityForIndex[index] = movedEntity;
    entityForIndex.remove(indexToMove);
    indexForEntity.remove(entity);
  }
  
  protected abstract bool canAddEntity(Entity entity);
  protected abstract ComponentType makeComponent(Entity entity);
  protected abstract void updateFromEntities();
  protected abstract void updateValues();
  protected abstract void updateEntities();
  
  int componentCount() @property { return components.length; }
  
  string className() @property
  {
    return this.classinfo.name.retro.until(".").to!string.retro.to!string;
  }
  
  void update()
  {
    StopWatch debugTimer;
    debugTimer.start;
    updateFromEntities();
    updateValues();
    updateEntities();
    debugTimingInternal = debugTimer.peek.usecs*0.001;
    debugTextInternal = format("%s components: %s\n%s timings: %s", 
                               className, components.length, className, debugTimingInternal);
  }
  
  size_t[const Entity] indexForEntity;
  Entity[size_t] entityForIndex;
  ComponentType[] components;
}
