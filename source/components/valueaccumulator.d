module components.valueaccumulator;

import std.algorithm;

import gl3n.aabb;
import gl3n.linalg;

import converters;
import entity;
import valuetypes;


interface ValueAccumulator
{
  void updateValues();
  
  Entity[] accumulatorSources() @property;
  void accumulatorSources(Entity[] entities) @property;
}

class ValueAccumulatorForType(ValueType) : ValueAccumulator
{
  Entity accumulatorTarget;
  
  Entity[] _accumulatorSources;
  //string[] accumulatorSourceNames;
  //long[] accumulatorSourceIds;
  //bool sourcesResolved = false;
  
  const string valueName;
  ValueType accumulator;
  
  Entity[] accumulatorSources() @property
  {
    return _accumulatorSources;
  }
  
  void accumulatorSources(Entity[] entities) @property
  {
    _accumulatorSources = entities;
  }
  
  invariant()
  {
    static if (is(ValueType == vec3))
      assert(accumulator.isFinite);
      
    static if (is(ValueType == double))
      assert(!accumulator.isNaN);
  }
  
  this(Entity accumulatorTarget, string valueName)
  {
    this.accumulatorTarget = accumulatorTarget;
    this.valueName = valueName;
    this.accumulator = DefaultValue!ValueType;
  }
  
  /*void preUpdateValues()
  {
    accumulator = DefaultValue!ValueType;
  }*/
  
  void updateValues()
  {
    accumulator = DefaultValue!ValueType;
  
    foreach (accumulatorSource; accumulatorSources)
    {
      static if (is(ValueType == vec2))
        accumulator += accumulatorSource.get!vec2(valueName);
      else static if (is(ValueType == vec3))
        accumulator += accumulatorSource.get!vec3(valueName);
      else static if(is(ValueType == double))
        accumulator += accumulatorSource.get!double(valueName);
      else
        assert(0);
    }
    
    accumulatorTarget[valueName] = accumulator;
  }
  
  /*void postUpdateValues()
  {
    accumulatorTarget[valueName] = accumulator;
  }*/
}
