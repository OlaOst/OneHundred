module systems.movement;

import gl3n.linalg;

import entity;
import system;


class Movement : System
{
  invariant()
  {
    assert(positions.length == velocities.length);
    
    // ensure there is a one-to-one mapping for indices in the arrays and the indexForEntity mapping
    foreach (const Entity entity, int index; indexForEntity)
    {
      assert(index >= 0 && index <= positions.length);
    }
  }

  vec2[] positions;
  vec2[] velocities;
  
  int[const Entity] indexForEntity;
  Entity[int] entityForIndex;
  
  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.vectors && "velocity" in entity.vectors;
  }
  
  override void addEntity(Entity entity)
  {
    if (canAddEntity(entity))
    {
      indexForEntity[entity] = positions.length;
      entityForIndex[positions.length] = entity;
      
      positions ~= entity.vectors["position"];
      velocities ~= entity.vectors["velocity"];
    }
  }
  
  override void update()
  {
    for (int index = 0; index < positions.length; index++)
    {
      positions[index] += velocities[index];
    }
  }
}
