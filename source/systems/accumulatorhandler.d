module systems.accumulatorhandler;

import std.algorithm;

import gl3n.linalg;

import components.valueaccumulator;
import entity;
import system;
import valuetypes;


class AccumulatorHandler : System!(ValueAccumulator[])
{
  bool canAddEntity(Entity entity)
  {
    // keep track of all entities with targets as they may be sources for value accumulation
    if (entity.has("relation.targetId"))
      entitiesWithTargetIdMapping[entity.get!long("relation.targetId")] ~= entity;
    if (entity.has("relation.targetName"))
    {
      auto targetName = entity.get!string("relation.targetName");
      entitiesWithTargetNameMapping[targetName] ~= entity;
    }
    
    return entity.has("valuestoaccumulate");
  }
  
  ValueAccumulator[] makeComponent(Entity entity)
  {
    ValueAccumulator[] valueAccumulators;
    
    auto valuesToAccumulateNames = entity.get!(string[])("valuestoaccumulate");
    
    foreach (valueToAccumulateName; valuesToAccumulateNames)
    {
      if (vec3Types.canFind(valueToAccumulateName))
        valueAccumulators ~= new ValueAccumulatorForType!vec3(entity, valueToAccumulateName);
        
      if (doubleTypes.canFind(valueToAccumulateName))
        valueAccumulators ~= new ValueAccumulatorForType!double(entity, valueToAccumulateName);
    }
    
    valueAccumulators.each!(accumulator => entityForAccumulator[accumulator] = entity);
    
    unresolvedAccumulators ~= valueAccumulators;
    
    return valueAccumulators;
  }
  
  void updateFromEntities() 
  {
    assert(resolvedAccumulators.all!(accumulator => accumulator.accumulatorSources.length > 0));
    assert(unresolvedAccumulators.all!(accumulator => accumulator.accumulatorSources.length == 0));
    
    foreach (accumulatorToResolve; unresolvedAccumulators)
    {
      Entity[] accumulatorSources;
      
      auto entity = entityForAccumulator[accumulatorToResolve];
      
      if (entity.id in entitiesWithTargetIdMapping)
        accumulatorSources ~= entitiesWithTargetIdMapping[entity.id];
        
      if (entity.has("fullName"))
      {
        auto fullName = entity.get!string("fullName");
 
        assert(fullName in entitiesWithTargetNameMapping, "Could not find " ~ fullName ~ " in mapping " ~ entitiesWithTargetNameMapping.to!string);
      
        accumulatorSources ~= entitiesWithTargetNameMapping[entity.get!string("fullName")];
      }
      
      accumulatorToResolve.accumulatorSources = accumulatorSources;
        
      resolvedAccumulators ~= accumulatorToResolve;
    }
    
    unresolvedAccumulators = null;
  }
  
  void updateValues()
  {
    foreach (resolvedAccumulator; resolvedAccumulators)
    {
      resolvedAccumulator.updateValues();
    }
  }
  
  void updateEntities()
  {
    // entity values should have been updated by the relation components
  }
  
  ValueAccumulator[] unresolvedAccumulators;
  ValueAccumulator[] resolvedAccumulators;
  
  Entity[ValueAccumulator] entityForAccumulator;
  
  Entity[][long] entitiesWithTargetIdMapping;
  Entity[][string] entitiesWithTargetNameMapping;
}
