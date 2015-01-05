module entity;

import std.algorithm;

import gl3n.linalg;

//import components.collider;
//import components.drawables.polygon;
//import components.drawables.sprite;
//import components.drawables.text;
//import components.input;
//import components.sound;
import converters;


class Entity
{
  string[string] values;
  
  ValueType get(ValueType)(string value)
  {
    return value in values ? values[value].to!ValueType : ValueType.init;
  }
  
  ValueType get(ValueType : double)(string value)
  {
    return value in values ? values[value].to!ValueType : 0.0;
  }
  
  ValueType get(ValueType : vec2)(string value)
  {
    return value in values ? values[value].myTo!vec2 : vec2(0.0, 0.0);
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
