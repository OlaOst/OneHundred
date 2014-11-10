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


class Graphics : System!bool
{
  this(int xres, int yres)
  {
    this.xres = xres; this.yres = yres;

    camera = new Camera();
  }

  override bool canAddEntity(Entity entity)
  {
    return false;
  }

  override bool makeComponent(Entity entity)
  {
    return false;
  }

  override void updateValues()
  {
    //debugText = format("graphics timings: %s", debugTimer.peek.usecs*0.001);
  }

  override void updateEntities()
  {
  }

  override void updateFromEntities()
  {
  }

  vec2 getWorldPositionFromScreenCoordinates(vec2 screenCoordinates)
  {
    return vec2(screenCoordinates.x / cast(float)xres - 0.5,
                0.5 - screenCoordinates.y / cast(float)yres) * (1.0 / camera.zoom) * 2.0;
  }

  immutable int xres, yres;
  Camera camera;
}
