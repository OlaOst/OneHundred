module entity;

import std.algorithm;

import gl3n.linalg;

import converters;


auto immutable vec2Types = ["position", "velocity", "force"];
auto immutable vec4Types = ["color"];
auto immutable doubleTypes = ["size", "angle", "rotation", "torque", "mass", "lifeTime"];
auto immutable fileTypes = ["sprite", "sound"];

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
    static if (is(ValueType == vec2))
      return vec2Values.get(valueName, defaultValue);
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
    static if (is(ValueType == vec2))
      vec2Values[valueName] = value;
    else static if (is(ValueType == vec4))
      vec4Values[valueName] = value;
    else static if (is(ValueType == double))
      doubleValues[valueName] = value;
      
    values[valueName] = value.to!string;
  }
  
  bool has(string valueName)
  {
    /*static if (is(ValueType == vec2))
      vec2Values[valueName] = value;
    else static if (is(ValueType == vec4))
      vec4Values[valueName] = value;
    else static if (is(ValueType == double))
      doubleValues[valueName] = value;*/
      
    return (valueName in values) !is null;
  }
  
  ValueType opIndex(ValueType)(string valueName)
  {
    return get(valueName);
  }
  
  string opIndex(string)(string valueName)
  {
    return get!string(valueName);
  }
  
  void opIndexAssign(ValueType)(ValueType value, string valueName)
  {
    set(valueName, value);
  }
  
  this()
  {
    id = idCounter++;
  }
  
  this(string[string] values)
  {
    this();
    this.values = values;
    
    foreach (key, value; values)
    {
      if (vec2Types.canFind(key))
        vec2Values[key] = value.myTo!vec2;
      if (vec4Types.canFind(key))
        vec4Values[key] = value.myTo!vec4;
      if (doubleTypes.canFind(key))
        doubleValues[key] = value.to!double;
    }
  }
  
  string debugInfo()
  {
    string info = "id: " ~ id.to!string;
    
    foreach (key, value; values)
      info ~= "\n" ~ key ~ ": " ~ value;
      
    return info;
  }
  
  vec2[string] vec2Values;
  vec4[string] vec4Values;
  double[string] doubleValues;
  string[string] values;
  immutable long id;
  static long idCounter = 0;
}
