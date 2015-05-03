module systems.relationhandler;

import std.algorithm;
import std.string;

import gl3n.aabb;
import gl3n.linalg;

import components.relation;
import components.relations.accumulatevalue;
import components.relations.dietogether;
import components.relations.inspectvalues;
import components.relations.relativevalue;
import components.relations.sameshape;
import converters;
import entity;
import system;
import valuetypes;


class RelationHandler : System!(Relation[])
{
  override bool canAddEntity(Entity entity)
  {
    // keep track of all entities as they might be targets for relation components
    entityIdMapping[entity.id] = entity;
    
    if (entity.has("fullName"))
      entityNameMapping[entity.get!string("fullName")] = entity;
    
    return entity.has("relation.types");
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
        
        if (vec3Types.canFind(relationValueName))
          relationComponents ~= new RelativeValue!vec3(entity, relationValueName, 
                                                       entity.get!vec3(relationValueKey));
        if (doubleTypes.canFind(relationValueName))
          relationComponents ~= new RelativeValue!double(entity, relationValueName, 
                                                         entity.get!double(relationValueKey));
      }
    }
    if (relationTypes.canFind("AccumulateValues"))
    {
      auto valuesToAccumulateNames = entity.values["relation.valuestoaccumulate"].to!(string[]);
      
      foreach (valueToAccumulateName; valuesToAccumulateNames)
      {
        if (vec3Types.canFind(valueToAccumulateName))
          relationComponents ~= new AccumulateValue!vec3(entity, valueToAccumulateName);
        
        if (doubleTypes.canFind(valueToAccumulateName))
          relationComponents ~= new AccumulateValue!double(entity, valueToAccumulateName);
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
    {
      sourceEntityMapping[relationComponent] = entity;
      
      if (entity.has("relation.targetId"))
      {
        targetIdForComponentMapping[relationComponent] = entity.get!long("relation.targetId");
        accumulatorSourceIdsMapping[entity.get!long("relation.targetId")] ~= entity.id;
      }
      else if (entity.has("relation.targetName"))
      {
        auto targetName = entity.get!string("relation.targetName");
        
        assert(targetName in entityNameMapping, "Could not find " ~ targetName ~ " in " ~ entityNameMapping.to!string ~ " for " ~ entity.values.to!string);
        
        auto targetId = entityNameMapping[targetName].id;
        targetIdForComponentMapping[relationComponent] = targetId;
        
        accumulatorSourceIdsMapping[targetId] ~= entity.id;
      }
      else if (entity.has("relation.valuestoaccumulate"))
        targetIdForComponentMapping[relationComponent] = entity.id; // just set target to self for accumulatorrelations, but should not be needed, TODO FIXME some other time maybe
    }
    
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
        if (auto accumulateValueComponent = cast(AccumulateValue!vec3)relationComponent)
        {
          accumulateValueComponent.preUpdateValues();
          
          // two-way, accumulate values of all components having this as relation
          foreach (accumulatorSourceRelationId; accumulatorSourceIdsMapping[accumulateValueComponent.accumulatorTarget.id].sort().uniq)
          {
            auto accumulatorSourceEntity = entityIdMapping[accumulatorSourceRelationId];
            accumulateValueComponent.updateValues(accumulatorSourceEntity);
          }
          
          accumulateValueComponent.postUpdateValues();
        }
        else if (auto accumulateValueComponent = cast(AccumulateValue!double)relationComponent)
        {
          accumulateValueComponent.preUpdateValues();

          // two-way, accumulate values of all components having this as relation
          foreach (accumulatorSourceRelationId; accumulatorSourceIdsMapping[accumulateValueComponent.accumulatorTarget.id].sort().uniq)
          {
            auto accumulatorSourceEntity = entityIdMapping[accumulatorSourceRelationId];
            accumulateValueComponent.updateValues(accumulatorSourceEntity);
          }
          
          accumulateValueComponent.postUpdateValues();
        }
        else
        {
          long targetId = targetIdForComponentMapping[relationComponent];
          Entity targetEntity = entityIdMapping[targetId];
          relationComponent.updateValues(targetEntity);
        }
      }
    }
  }
  
  override void updateEntities()
  {
    // entity values should have been updated by the relation components
  }
  
  Entity[string] entityNameMapping;
  Entity[long] entityIdMapping;
  long[Relation] targetIdForComponentMapping;
  Entity[Relation] sourceEntityMapping;
  long[][long] accumulatorSourceIdsMapping;
}
