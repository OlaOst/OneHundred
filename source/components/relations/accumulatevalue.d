module components.relations.accumulatevalue;

import std.algorithm;

import inmath.aabb;
import inmath.linalg;

import components.relation;
import converters;
import entity;
import valuetypes;


class AccumulateValue(ValueType) : Relation
{
  Entity accumulatorTarget;
  const string valueName;
  ValueType accumulator;
  
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
  
  void preUpdateValues()
  {
    accumulator = DefaultValue!ValueType;
  }
  
  void updateValues(Entity accumulatorSource)
  {
    static if (is(ValueType == vec2))
      accumulator += accumulatorSource.get!vec2(valueName);
    else static if (is(ValueType == vec3))
      accumulator += accumulatorSource.get!vec3(valueName);
    else static if(is(ValueType == double))
      accumulator += accumulatorSource.get!double(valueName);
    else
      assert(0);
      
    accumulatorTarget[valueName] = accumulator;
  }
  
  void postUpdateValues()
  {
    accumulatorTarget[valueName] = accumulator;
  }
}
