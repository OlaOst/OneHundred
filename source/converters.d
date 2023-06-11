module converters;

import std.algorithm;
import std.array;
import std.conv;
import std.math;

import inmath.aabb;
import inmath.linalg;


type myTo(type : vec2)(string text)
{
  return vec2(text.to!(float[]));
}

type myTo(type : vec3)(string text)
{
  return vec3(text.to!(float[]));
}

type myTo(type : vec4)(string text)
{
  return vec4(text.to!(float[]));
}

type myTo(type : vec2[])(string text)
{
  return text.to!(float[2][]).map!(v => vec2(v)).array;
}

type myTo(type : vec3[])(string text)
{
  return text.to!(float[3][]).map!(v => vec3(v)).array;
}

type myTo(type : vec4[])(string text)
{
  return text.to!(float[4][]).map!(v => vec4(v)).array;
}

type myTo(type : AABB)(string text)
{
  auto points = text.myTo!(vec3[]);
  return AABB.fromPoints(points);
}

vec2 vec2FromAngle(double angle)
{
  return vec2(cos(angle), sin(angle));
}
