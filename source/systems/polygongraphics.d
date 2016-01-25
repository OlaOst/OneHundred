module systems.polygongraphics;

import std.algorithm;
import std.array;
import std.datetime;
import std.range;
import std.stdio;

import gl3n.linalg;
import glamour.texture;

import components.collider;
import components.drawables.polygon;
import converters;
import entity;
import entityfactory.entities;
import system;
import systems.graphics;


class PolygonGraphics : Graphics!Polygon
{
  this(int xres, int yres)
  {
    super(xres, yres);
    dummyTexture = new Texture2D();
    dummyTexture.set_data([0, 0, 0, 0], GL_RGBA, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE);
  }

  override void close()
  {
    dummyTexture.remove();
  }
  
  bool canAddEntity(Entity entity)
  {
    return entity.has("position") && ((entity.polygon !is null) || entity.has("polygon.vertices"));
  }

  Polygon makeComponent(Entity entity)
  {
    Polygon component = entity.polygon ? entity.polygon : parsePolygonFromEntity(entity);
    entity.polygon = component;
    assert(entity.polygon !is null);
    
    component.position = entity.get!vec3("position");
    component.angle = entity.get!double("angle");

    return component;
  }

  void updateValues()
  {
    StopWatch debugTimer;
    debugTimer.start;
    vertices = null;
    colors = null;
    
    foreach (component; components)
    {
      auto transform = (vec3 vertex) => (vertex * mat3.zrotation(-component.angle) +
                                         component.position);
      // map with delegate in a variable and then array crashes with release build in dmd 2.069
      //vertices["polygon"] ~= component.vertices.map!transform.array;
      vec3[] transformedVertices;
      foreach (vertex; component.vertices)
        transformedVertices ~= transform(vertex);
      vertices["polygon"] ~= transformedVertices;
      colors["polygon"] ~= component.colors;
    }
    debugText = format("polygongraphics timings: %s", debugTimer.peek.usecs*0.001);
  }

  void updateEntities() {}

  void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      assert(entity.polygon !is null);
      components[index].position = entity.get!vec3("position");
      components[index].angle = entity.get!double("angle");
      components[index].vertices = entity.polygon.vertices;
      components[index].colors = entity.polygon.colors;
    }
  }

  vec3[][string] vertices;
  vec4[][string] colors;
  Texture2D dummyTexture;
}
