module systems.relationhandler;

import std.algorithm;

import gl3n.linalg;

import components.relation;
import components.relations.dietogether;
import components.relations.relativeposition;
import converters;
import entity;
import system;


class RelationHandler : System!(Relation[])
{
  override bool canAddEntity(Entity entity)
  {
    // register all entities as they might be targets for relation components
    entityIdMapping[entity.id] = entity;
    return ("relation.types" in entity.values) !is null;
  }
  
  override Relation[] makeComponent(Entity entity)
  {
    Relation[] relationComponents;
    
    auto relationTypes = entity.values["relation.types"].to!(string[]);
    
    if (relationTypes.canFind("RelativePosition"))
    {
      vec2 relativePosition = vec2(0.0, 0.0);
      if ("relativePosition" in entity.values)
        relativePosition = entity.values["relativePosition"].myTo!vec2;
      relationComponents ~= new RelativePosition(entity, relativePosition);
    }
    if (relationTypes.canFind("DieTogether"))
    {
      relationComponents ~= new DieTogether(entity);
    }
    
    foreach (relationComponent; relationComponents)
      targetIdMapping[relationComponent] = entity.values["relation.targetId"].to!long;

    return relationComponents;
  }
  
  override void updateFromEntities()
  {
    // TODO: ensure relativePosition/etc of components get updated if entity values are updated
    // ie mouse drag to change relativePosition of an entity
  }
  
  override void updateValues()
  {
    foreach (relationComponents; components)
    {
      foreach (relationComponent; relationComponents)
      {
        long targetId = targetIdMapping[relationComponent];
        Entity targetEntity = entityIdMapping[targetId];
        relationComponent.updateValues(targetEntity);
      }
    }
  }
  
  override void updateEntities()
  {
    // entity values should have been updated by the relation components
    /*foreach (uint index, Entity entity; entityForIndex)
    {
      components[index]
    }*/
  }
  
  Entity[long] entityIdMapping;
  long[Relation] targetIdMapping;
}
