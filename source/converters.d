module converters;

import std.algorithm;
import std.array;
import std.conv;

import gl3n.linalg;


type myTo(type : vec2)(string text)
{
  return vec2(text.to!(float[]));
}

type myTo(type : vec2[])(string text)
{
  return text.to!(float[2][]).map!(v => vec2(v)).array;
}

vec2 vec2FromAngle(double angle)
{
  return vec2(cos(angle), sin(angle));
}
