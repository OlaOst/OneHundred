module converters;

import std.algorithm;
import std.array;
import std.conv;

import gl3n.aabb;
import gl3n.linalg;


type myTo(type : vec2)(string text)
{
  return vec2(text.to!(float[]));
}

type myTo(type : vec4)(string text)
{
  return vec4(text.to!(float[]));
}

type myTo(type : vec2[])(string text)
{
  return text.to!(float[2][]).map!(v => vec2(v)).array;
}

type myTo(type : vec4[])(string text)
{
  return text.to!(float[4][]).map!(v => vec4(v)).array;
}

type myTo(type : AABB)(string text)
{
  auto points = text.myTo!(vec2[]);
  return AABB.from_points(points.map!(point => vec3(point, 0.0)).array);
}

vec2 vec2FromAngle(double angle)
{
  return vec2(cos(angle), sin(angle));
}
