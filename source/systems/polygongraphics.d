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
    return entity.has("position") && entity.has("polygon.vertices") && (entity.has("polygon.colors") || entity.has("color"));
  }

  override Polygon makeComponent(Entity entity)
  {
    Polygon component;

    // TODO: maybe split into separate systems for drawing polygons/texts/sprites?
    if (entity.has("polygon.vertices"))
    {
      if (entity.has("polygon.colors"))
        component = new Polygon(entity.get!(vec2[])("polygon.vertices"),
                                entity.get!(vec4[])("polygon.colors"));
      else if (entity.has("color"))
        component = new Polygon(entity.get!(vec2[])("polygon.vertices"),
                                entity.get!vec4("color"));
    }

    component.position = entity.get!vec2("position");
    component.angle = entity.get!double("angle");
    
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
      //vertices["polygon"] ~= component.vertices.map!transform.array;
      vec2[] transformedVertices;
      foreach (vertex; component.vertices)
        transformedVertices ~= transform(vertex);
      vertices["polygon"] ~= transformedVertices;
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
      components[index].position = entity.get!vec2("position");
      components[index].angle = entity.get!double("angle");
      
      components[index].vertices = entity.get!(vec2[])("polygon.vertices");
      components[index].colors = entity.get!(vec4[])("polygon.colors");
    }
  }

  immutable int xres, yres;
  Camera camera;
  vec2[][string] vertices;
  vec4[][string] colors;
}
