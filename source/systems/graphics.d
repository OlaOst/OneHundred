module systems.graphics;

import std.algorithm;
import std.array;
import std.datetime;
import std.stdio;

import glamour.texture;
import gl3n.linalg;

import camera;
import components.collider;
import converters;
import entity;
import system;


abstract class Graphics(ComponentType) : System!ComponentType
{
  this(int xres, int yres)
  {
    this.xres = xres; this.yres = yres;
  }

  immutable int xres, yres;
}

void fillBuffer(Type)(Type[] buffer, Type[] source, ref size_t index) @nogc
{
  buffer[index .. index + source.length] = source;
  index += source.length;
}

vec3 getWorldPositionFromScreenCoordinates(Camera camera, vec2 screenCoordinates, 
                                           int xres, int yres)
{
  return camera.transform(vec3(screenCoordinates.x / cast(float)xres - 0.5,
                               0.5 - screenCoordinates.y / cast(float)yres,
                               0.0));
}
