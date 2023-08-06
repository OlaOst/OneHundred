module systems.accumulatorhandler;

import std;

import inmath.linalg;

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
      entitiesWithTargetNameMapping[entity.get!string("relation.targetName")] ~= entity;
    return entity.has("valuestoaccumulate");
  }
  
  override void tweakEntity(ref Entity entity)
  {
    if ("valuestoaccumulate" in entity.values)
    {
      foreach (valueToAccumulate; entity.values["valuestoaccumulate"].to!(string[]))
      {
        if (valueToAccumulate !in entity.values)
        {
          if (vec3Types.canFind(valueToAccumulate))
            entity[valueToAccumulate] = DefaultValue!vec3;
          if (vec4Types.canFind(valueToAccumulate))
            entity[valueToAccumulate] = DefaultValue!vec4;
          if (doubleTypes.canFind(valueToAccumulate))
            entity[valueToAccumulate] = DefaultValue!double;
          if (valueToAccumulate == "mass")
            entity["mass"] = 0.001;
        }
      }
    }
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
        assert(entity.get!string("fullName") in entitiesWithTargetNameMapping, 
               "Could not find " ~ entity.get!string("fullName") ~ 
               " in mapping " ~ entitiesWithTargetNameMapping.to!string);
        accumulatorSources ~= entitiesWithTargetNameMapping[entity.get!string("fullName")];
      }
      accumulatorToResolve.accumulatorSources = accumulatorSources;
      resolvedAccumulators ~= accumulatorToResolve;
    }
    unresolvedAccumulators = null;
  }
  
  void updateValues(bool paused)
  {
    resolvedAccumulators = resolvedAccumulators.filter!(resolvedAccumulator => 
      entityForAccumulator[resolvedAccumulator].get!bool("ToBeRemoved") == false).array;
    resolvedAccumulators.each!(resolvedAccumulator => resolvedAccumulator.updateValues());
  }
  
  // entity values should have been updated by the relation components
  void updateEntities() {}
  
  override void update(bool paused)
  {
    if (!paused)
      super.update(paused);
  }
  
  ValueAccumulator[] unresolvedAccumulators;
  ValueAccumulator[] resolvedAccumulators;
  Entity[ValueAccumulator] entityForAccumulator;
  Entity[][long] entitiesWithTargetIdMapping;
  Entity[][string] entitiesWithTargetNameMapping;
}
