module systems.spritegraphics;

import std.algorithm;
import std.array;
import std.datetime;
import std.stdio;

import glamour.texture;
import gl3n.linalg;

import camera;
import components.collider;
import components.drawables.sprite;
import converters;
import entity;
import system;
import systems.graphics;


class SpriteGraphics : Graphics!Sprite
{
  this(int xres, int yres, Camera camera)
  {
    super(xres, yres, camera);
  }

  ~this()
  {
    foreach (name, texture; textureSet)
    {
      texture.remove();
    }
  }
  
  override bool canAddEntity(Entity entity)
  {
    return entity.has("position") && entity.has("size") && entity.has("sprite");
  }

  override Sprite makeComponent(Entity entity)
  {
    assert(canAddEntity(entity));

    auto component = new Sprite(entity.get!double("size"), entity.get!string("sprite"));

    textureSet[entity.get!string("sprite")] = component.texture;

    component.position = entity.get!vec2("position");
    component.angle = entity.get!double("angle");

    return component;
  }

  override void updateValues()
  {
    StopWatch debugTimer;
    debugTimer.start;
    vertices = texCoords = null;
    colors = null;

    foreach (component; components)
    {
      auto transform = (vec2 vertex) => ((vec3(vertex, 0.0)*mat3.zrotation(-component.angle)).xy +
                                         component.position - camera.position) *
                                         camera.zoom;

      // map with delegate in a variable and then array crashes with release build in dmd 2.066
      //vertices[component.fileName] ~= component.vertices.map!transform.array;
      foreach (vertex; component.vertices)
        vertices[component.fileName] ~= transform(vertex);
      texCoords[component.fileName] ~= component.texCoords;
    }
    debugText = format("spritegraphics timings: %s", debugTimer.peek.usecs*0.001);
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
    }
  }

  vec2[][string] vertices, texCoords;
  vec4[][string] colors;
  Texture2D[string] textureSet;
}
