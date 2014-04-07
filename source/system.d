module system;

import entity;


class System
{
  invariant()
  {    
    // ensure there is a one-to-one mapping between indices and entities
    for (int index = 0; index < indexForEntity.length; index++)
    {
      assert(index in entityForIndex);
      assert(entityForIndex[index] in indexForEntity);
      assert(entityForIndex[index] == entityForIndex[indexForEntity[entityForIndex[index]]]);
    }
  }
  
  int[const Entity] indexForEntity;
  Entity[int] entityForIndex;
  
  abstract bool canAddEntity(Entity entity);
  abstract void addEntity(Entity entity);
  abstract void update();
}
