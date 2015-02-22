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
  this(int xres, int yres, Camera camera)
  {
    this.xres = xres; this.yres = yres;
    this.camera = camera;
  }

  immutable int xres, yres;
  Camera camera;
}

size_t fillBuffer(Type)(Type[] buffer, Type[] source, size_t index) @nogc
{
  buffer[index .. index + source.length] = source;
  return source.length;
}

vec2 getWorldPositionFromScreenCoordinates(Camera camera, vec2 screenCoordinates, int xres, int yres)
{
  return camera.transform(vec2(screenCoordinates.x / cast(float)xres - 0.5,
                               0.5 - screenCoordinates.y / cast(float)yres));
}
