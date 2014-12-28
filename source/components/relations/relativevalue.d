module components.relations.relativevalue;

import gl3n.aabb;
import gl3n.linalg;

import components.relation;
import converters;
import entity;


class RelativeValue(ValueType) : Relation
{
  Entity source;
  const string valueName;
  const ValueType relativeValue;
  
  // TODO: this constructor should only be used for AABB types
  this(Entity source, string valueName)
  {
    this.source = source;
    this.valueName = valueName;
    this.relativeValue = ValueType.init;//relativeValue;
  }
  
  this(Entity source, string valueName, ValueType relativeValue)
  {
    this.source = source;
    this.valueName = valueName;
    this.relativeValue = relativeValue;
  }
  
  void updateValues(Entity target)
  {
    static if (is(ValueType == vec2))
      auto newValue = target.values[valueName].myTo!vec2 + relativeValue;
    //else static if (is(ValueType == AABB))
      //auto newValue = target.values[valueName].myTo!AABB; // no meaningful relativevalue for AABBs
    else
      auto newValue = target.values[valueName].to!ValueType + relativeValue;
      
    //import std.stdio;
    //writeln("setting ", source.id, ".", valueName, " from ", (valueName in source.values ? source.values[valueName] : "null"), " to ", newValue);
    
    source.values[valueName] = newValue.to!string;
  }
}
