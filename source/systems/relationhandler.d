module systems.relationhandler;

import std.algorithm;
import std.string;

import gl3n.aabb;
import gl3n.linalg;

import components.relation;
import components.relations.dietogether;
import components.relations.inspectvalues;
import components.relations.relativevalue;
import components.relations.sameshape;
import converters;
import entity;
import system;


class RelationHandler : System!(Relation[])
{
  override bool canAddEntity(Entity entity)
  {
    // keep track of all entities as they might be targets for relation components
    entityIdMapping[entity.id] = entity;
    return ("relation.types" in entity.values) !is null;
  }
  
  override Relation[] makeComponent(Entity entity)
  {
    Relation[] relationComponents;
    
    auto relationTypes = entity.get!(string[])("relation.types");
    
    if (relationTypes.canFind("RelativeValues"))
    {
      foreach (relationValueKey; entity.values.keys.filter!
                                 (key => key.startsWith("relation.value.")))
      {
        auto relationValueName = relationValueKey.chompPrefix("relation.value.");
        
        auto immutable vec2Types = ["position", "velocity", "force"];
        auto immutable doubleTypes = ["size", "angle", "rotation", "torque"];
        
        if (vec2Types.canFind(relationValueName))
          relationComponents ~= new RelativeValue!vec2(entity, relationValueName, 
                                                       entity.get!vec2("relationValueKey"));
        if (doubleTypes.canFind(relationValueName))
          relationComponents ~= new RelativeValue!double(entity, relationValueName, 
                                                         entity.get!double("relationValueKey"));
      }
    }
    if (relationTypes.canFind("DieTogether"))
    {
      relationComponents ~= new DieTogether(entity);
    }
    if (relationTypes.canFind("InspectValues"))
    {
      relationComponents ~= new InspectValues(entity);
    }
    if (relationTypes.canFind("SameShape"))
    {
      relationComponents ~= new SameShape(entity);
    }
    
    foreach (relationComponent; relationComponents)
      targetIdMapping[relationComponent] = entity.values["relation.targetId"].to!long;

    return relationComponents;
  }
  
  override void updateFromEntities()
  {
    // TODO: ensure relativeValue/etc of components get updated if entity values are updated
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
  }
  
  Entity[long] entityIdMapping;
  long[Relation] targetIdMapping;
}
