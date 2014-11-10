module systems.polygongraphics;

import std.algorithm;
import std.array;
import std.datetime;
import std.stdio;

import glamour.texture;
import gl3n.linalg;

import camera;
import components.collider;
import components.drawable;
import components.drawables.polygon;
import components.drawables.sprite;
import components.drawables.text;
import converters;
import entity;
import system;


class PolygonGraphics : System!Polygon
{
  this(int xres, int yres, Camera camera)
  {
    this.xres = xres; this.yres = yres;
    this.camera = camera;
  }

  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.values && "angle" in entity.values &&
           Polygon.canMakeComponent(entity.values);
  }

  override Polygon makeComponent(Entity entity)
  {
    Polygon component;

    // TODO: maybe split into separate systems for drawing polygons/texts/sprites?
    if ("polygon.vertices" in entity.values)
    {
      if ("polygon.colors" in entity.values)
        component = new Polygon(entity.values["polygon.vertices"].myTo!(vec2[]),
                                entity.values["polygon.colors"].myTo!(vec4[]));
      else if ("color" in entity.values)
        component = new Polygon(entity.values["polygon.vertices"].myTo!(vec2[]),
                                entity.values["color"].myTo!vec4);
    }

    component.position = vec2(entity.values["position"].to!(float[2]));
    component.angle = entity.values["angle"].to!double;

    return component;
  }

  override void updateValues()
  {
    StopWatch debugTimer;
    debugTimer.start;
    vertices = null;
    colors = null;

    foreach (component; components)
    {
      auto transform = (vec2 vertex) => ((vec3(vertex, 0.0)*mat3.zrotation(-component.angle)).xy +
                                         component.position - camera.position) *
                                         camera.zoom;

      // map with delegate in a variable and then array crashes with release build in dmd 2.066
      vertices["polygon"] ~= component.vertices.map!transform.array;
      colors["polygon"] ~= component.colors;
    }
    debugText = format("polygongraphics timings: %s", debugTimer.peek.usecs*0.001);
  }

  override void updateEntities()
  {
  }

  override void updateFromEntities()
  {
    foreach (uint index, Entity entity; entityForIndex)
    {
      //currentStates[index].velocity = entity.vectors["velocity"];
      components[index].position = vec2(entity.values["position"].to!(float[2]));
      components[index].angle = entity.values["angle"].to!double;
    }
  }


  immutable int xres, yres;
  Camera camera;
  vec2[][string] vertices;
  vec4[][string] colors;
}
