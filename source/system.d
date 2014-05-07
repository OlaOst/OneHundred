module system;

import std.array;
import std.conv;

import entity;


class System(ComponentType)
{
  invariant()
  {
    assert(indexForEntity.length == entityForIndex.length, 
           "indexForEntity/entityForIndex length mismatch");
    assert(indexForEntity.length == components.length, 
           "indexForEntity/components length mismatch");
    
    // ensure there is a one-to-one mapping between indices and entities
    foreach (int index, const Entity entity; entityForIndex)
    {
      assert(index in entityForIndex);
      assert(entity in indexForEntity);
      assert(entityForIndex[index] == entity);
      assert(indexForEntity[entity] == index);
      assert(index >= 0 && index < components.length, 
             "index " ~ index.to!string ~ " out of bounds: " ~ components.length.to!string);
    }
  }
  
  int[const Entity] indexForEntity;
  Entity[int] entityForIndex;
  ComponentType[] components;
  string debugText;
  
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
    if (entity in indexForEntity)
    {
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
  }
    
  abstract bool canAddEntity(Entity entity);
  abstract ComponentType makeComponent(Entity entity);
  abstract void update();
}
