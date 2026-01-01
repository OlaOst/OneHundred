module systems.relationhandler;

import std;

import inmath.linalg;

import components.relation;
import components.relations.dietogether;
import components.relations.inspectvalues;
import components.relations.relativevalue;
import components.relations.relativeconstraint;
import components.relations.sameshape;
import entity;
import system;
import valuetypes;


class RelationHandler : System!(Relation[])
{
  bool canAddEntity(Entity entity)
  {
    // keep track of all entities as they may be targets for relation components
    entityIdMapping[entity.id] = entity;
    
    if (entity.has("fullName"))
      entityNameMapping[entity.get!string("fullName")] = entity;
    
    return entity.has("relation.types");
  }
  
  Relation[] makeComponent(Entity entity)
  {
    Relation[] relationComponents;
    auto relationTypes = entity.get!(string[])("relation.types");
    
    if (relationTypes.canFind("RelativeValues"))
    {
      foreach (relationValueKey; entity.values.byKey.filter!
                                 (key => key.startsWith("relation.value.")))
      {
        auto relationValueName = relationValueKey.chompPrefix("relation.value.");

        if (vec3Types.canFind(relationValueName))
          relationComponents ~= new RelativeValue!vec3(entity, relationValueName, 
                                                       entity.get!vec3(relationValueKey));
        if (doubleTypes.canFind(relationValueName))
          relationComponents ~= new RelativeValue!double(entity, relationValueName, 
                                                         entity.get!double(relationValueKey));
      }
    }
    if (relationTypes.canFind("DieTogether"))
      relationComponents ~= new DieTogether(entity);
    if (relationTypes.canFind("InspectValues"))
      relationComponents ~= new InspectValues(entity);
    if (relationTypes.canFind("SameShape"))
      relationComponents ~= new SameShape(entity);
    if (relationTypes.canFind("RelativeConstraints"))
    {
      foreach (relationValueKey; entity.values.byKey.filter!
                                 (key => key.startsWith("relation.value.")))
      {
        auto relationValueName = relationValueKey.chompPrefix("relation.value.");
        relationComponents ~= new RelativeConstraint!double(entity, relationValueName, entity.get!double(relationValueKey));
      }
    }
    
    foreach (relationComponent; relationComponents)
    {
      if (entity.has("relation.targetId"))
      {
        targetIdForComponentMapping[relationComponent] = entity.get!long("relation.targetId");
      }
      else if (entity.has("relation.targetName"))
      {
        auto targetName = entity.get!string("relation.targetName");
        assert(targetName in entityNameMapping, 
               "Could not find " ~ targetName ~ " in " ~ entityNameMapping.keys.to!string ~ 
               " with values " ~ entityNameMapping.values.map!(e => e.values).to!string);
        targetIdForComponentMapping[relationComponent] = entityNameMapping[targetName].id;
      }
    }
    
    return relationComponents;
  }
  
  // TODO: ensure relativeValue/etc of components get updated if entity values are updated
  // ie mouse drag to change relativePosition of an entity
  void updateFromEntities() {}
  
  void updateValues(bool paused)
  {
    foreach (relationComponents; components)
    {
      foreach (relationComponent; relationComponents)
      {
        long targetId = targetIdForComponentMapping[relationComponent];
        relationComponent.updateValues(entityIdMapping[targetId]);
      }
    }
  }
  
  // entity values should have been updated by the relation components
  void updateEntities() {}
  
  override void update(bool paused)
  {
    if (!paused)
      super.update(paused);
  }
  
  Entity[string] entityNameMapping;
  Entity[long] entityIdMapping;
  long[Relation] targetIdForComponentMapping;
}
