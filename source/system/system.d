module system.system;

import entity;


class System
{
  invariant()
  {
    //assert(positions.length == velocities.length);
    
    // ensure there is a one-to-one mapping for indices in the arrays and the indexForEntity mapping
    /*foreach (const Entity entity, int index; indexForEntity)
    {
      assert(index >= 0 && index <= positions.length);
    }*/
    
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
