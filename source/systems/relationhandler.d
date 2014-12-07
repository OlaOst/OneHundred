module systems.relationhandler;

import std.algorithm;

import gl3n.linalg;

import converters;
import entity;
import system;


interface Relation
{
  void updateValues(Entity target);
}

class DieTogetherRelation : Relation
{
  Entity source;
  
  this(Entity source)
  {
    this.source = source;
  }
  
  void updateValues(Entity target)
  {
    source.toBeRemoved = target.toBeRemoved;
  }
}

class RelativePositionRelation : Relation
{
  Entity source;
  const vec2 relativePosition;
  
  this(Entity source, vec2 relativePosition)
  {
    this.source = source;
    this.relativePosition = relativePosition;
  }
  
  void updateValues(Entity target)
  {
    auto newPosition = target.values["position"].myTo!vec2 + relativePosition;
    source.values["position"] = newPosition.to!string;
  }
}

class RelationHandler : System!(Relation[])
{
  override bool canAddEntity(Entity entity)
  {
    entityIdMapping[entity.id] = entity; // register all entities as they might be targets for relation components
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
      relationComponents ~= new RelativePositionRelation(entity, relativePosition);
    }
    if (relationTypes.canFind("DieTogether"))
    {
      relationComponents ~= new DieTogetherRelation(entity);
    }
    
    foreach (relationComponent; relationComponents)
      targetIdMapping[relationComponent] = entity.values["relation.targetId"].to!long; // the target entity may not have been registered yet

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
