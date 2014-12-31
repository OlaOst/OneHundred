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
  
  this(Entity source, string valueName)
  {
    this.source = source;
    this.valueName = valueName;
    this.relativeValue = ValueType.init;
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
    else
      auto newValue = target.values[valueName].to!ValueType + relativeValue;
    
    source.values[valueName] = newValue.to!string;
  }
}
