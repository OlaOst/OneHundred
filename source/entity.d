module entity;

import std.algorithm;

import gl3n.linalg;

import converters;


class Entity
{
  string[string] values;
  
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
  
  //double[string] scalars;
  //vec2[string] vectors;
  //vec4[string] bigVectors;
  
  // temp drawable stuff
  //Polygon polygon;
  //Text text;
  //Sprite sprite;
  
  // temp stuff
  //Input input;
  //string editText;
  //Sound sound;
  //Collider collider;
  
  bool toBeRemoved = false;
  
  static long idCounter = 0;
  immutable long id;
  
  this()
  {
    id = idCounter++;
  }
  
  string debugInfo()
  {
    string info = "id: " ~ id.to!string;
    
    foreach (key, value; values)
      info ~= "\n" ~ key ~ ": " ~ value;
    //foreach (key, value; scalars)
      //info ~= "\n" ~ key ~ ": " ~ value.to!string;
      
    return info;
  }
}
