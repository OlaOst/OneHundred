module entity;

import std.algorithm;

import gl3n.linalg;

import converters;


class Entity
{
  static ValueType DefaultValue(ValueType)()
  {
    static if (is(ValueType == double))
      return 0.0;
    else static if (is(ValueType == vec2))
      return vec2(0.0, 0.0);
    else static if (is(ValueType == vec4))
      return vec4(0.0, 0.0, 0.0, 0.0);
    else
      return ValueType.init;
  }
  
  ValueType get(ValueType)(string valueName, 
                           lazy ValueType defaultValue = DefaultValue!ValueType) const
  {
    if (auto value = valueName in values)
      static if (__traits(compiles, (*value).to!ValueType))
        return (*value).to!ValueType;
      else
        return (*value).myTo!ValueType;
    else
      return defaultValue;
  }  
  
  this()
  {
    id = idCounter++;
  }
  
  string debugInfo()
  {
    string info = "id: " ~ id.to!string;
    
    foreach (key, value; values)
      info ~= "\n" ~ key ~ ": " ~ value;
      
    return info;
  }
  
  string[string] values;
  immutable long id;
  static long idCounter = 0;
}
