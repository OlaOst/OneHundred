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
  
  this(Entity source, string valueName, ValueType relativeValue)
  {
    this.source = source;
    this.valueName = valueName;
    this.relativeValue = relativeValue;
  }
  
  void updateValues(Entity target)
  {
    static if (is(ValueType == vec2))
      auto newValue = target.get!vec2(valueName) + relativeValue;
    else static if (is(ValueType == vec3))
    {
      auto newValue = (valueName == "position" && target.has("angle")) ? (target.get!vec3(valueName) + mat3.zrotation(target.get!double("angle")) * relativeValue) 
                                                : target.get!vec3(valueName) + relativeValue;
    }
    else static if(is(ValueType == double))
      auto newValue = target.get!double(valueName) + relativeValue;
    else
      assert(0);
      
    source[valueName] = newValue;
  }
}
