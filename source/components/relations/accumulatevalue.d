module components.relations.accumulatevalue;

import gl3n.aabb;
import gl3n.linalg;

import components.relation;
import converters;
import entity;
import valuetypes;


class AccumulateValue(ValueType) : Relation
{
  Entity source;
  const string valueName;
  ValueType accumulator;
  
  invariant()
  {
    static if (is(ValueType == vec3))
      assert(accumulator.isFinite);
      
    static if (is(ValueType == double))
      assert(!accumulator.isNaN);
  }
  
  this(Entity source, string valueName)
  {
    this.source = source;
    this.valueName = valueName;
    this.accumulator = DefaultValue!ValueType;
  }
  
  void preUpdateValues()
  {
    accumulator = DefaultValue!ValueType;
  }
  
  void updateValues(Entity target)
  {
    static if (is(ValueType == vec2))
      accumulator += target.get!vec2(valueName);
    else static if (is(ValueType == vec3))
      accumulator += target.get!vec3(valueName);
    else static if(is(ValueType == double))
    {
      //import std.stdio;
      //writeln("accumulatevalue updatevalues adding ", target.get!double(valueName), " to ", valueName, " from ", target.get!string("fullName"), ", accumulator is " , accumulator);
      accumulator += target.get!double(valueName);
    }
    else
      assert(0);
    
    //target[valueName] = newValue;
  }
  
  void postUpdateValues()
  {
    //import std.stdio;
    //writeln("accumulatevalue postupdatevalues setting value ", valueName, " on ", source.get!string("fullName"), " to ", accumulator, ", position is ", source.get!vec3("position"), ", velocity is ", source.get!vec3("velocity"));
    source[valueName] = accumulator;
  }
}
