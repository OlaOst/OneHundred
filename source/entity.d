module entity;

import std.algorithm;

import gl3n.linalg;

import components.drawables.polygon;
import converters;
import valueparser;
import valuetypes;


class Entity
{
  ValueType get(ValueType)(string valueName, 
                           lazy ValueType defaultValue = DefaultValue!ValueType) const
  {
    static if (is(ValueType == vec3))
      return vec3Values.get(valueName, defaultValue);
    else static if (is(ValueType == vec4))
      return vec4Values.get(valueName, defaultValue);
    else static if (is(ValueType == double))
      return doubleValues.get(valueName, defaultValue);    
    else if (auto value = valueName in values)
      static if (__traits(compiles, (*value).to!ValueType))
        return (*value).to!ValueType;
      else
        return (*value).myTo!ValueType;
    else
      return defaultValue;
  }
  
  void set(ValueType)(string valueName, ValueType value)
  {
    static if (is(ValueType == vec3))
      vec3Values[valueName] = value;
    else static if (is(ValueType == vec4))
      vec4Values[valueName] = value;
    else static if (is(ValueType == double))
      doubleValues[valueName] = value;
    values[valueName] = value.to!string;
  }
  
  bool has(string valueName)
  {
    return (valueName in values) !is null;
  }
  
  string opIndex(string valueName)
  {
    return values[valueName];
  }
  
  void opIndexAssign(ValueType)(ValueType value, string valueName)
  {
    set(valueName, value);
  }
  
  this() { id = idCounter++; }
  
  this(string[string] values)
  {
    this();
    this.values = values.parseValues;

    foreach (key, value; values)
    {
      auto fixKey = key;
      fixKey.findSkip("relation.value.");
    
      if (fixKey !in values)
        values[fixKey] = value;
      if (vec3Types.canFind(fixKey))
        vec3Values[key] = value.myTo!vec3;
      if (vec4Types.canFind(fixKey))
        vec4Values[key] = value.myTo!vec4;
      if (doubleTypes.canFind(fixKey))
        doubleValues[key] = value.to!double;
    }
  }
  
  string debugInfo()
  {
    string info = "id: " ~ id.to!string;
    values.each!((key, value) => info ~= "\n" ~ key ~ ": " ~ value);
    return info;
  }
  
  // polygon data should be in values, but we need a 'denormalization' here for performance reasons
  Polygon polygon;
  vec3[string] vec3Values;
  vec4[string] vec4Values;
  double[string] doubleValues;
  string[string] values;
  immutable long id;
  static long idCounter = 0;
}
