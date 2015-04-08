module systems.spritegraphics;

import std.algorithm;
import std.array;
import std.datetime;
import std.stdio;

import glamour.texture;
import gl3n.linalg;

import components.collider;
import components.drawables.sprite;
import converters;
import entity;
import system;
import systems.graphics;


class SpriteGraphics : Graphics!Sprite
{
  this(int xres, int yres)
  {
    super(xres, yres);
  }

  void close()
  {
    foreach (name, texture; textureSet)
      texture.remove();
  }

  override bool canAddEntity(Entity entity)
  {
    return entity.has("position") && entity.has("size") && entity.has("sprite");
  }

  override Sprite makeComponent(Entity entity)
  {
    assert(canAddEntity(entity));

    auto fileName = entity.get!string("sprite");
    if (fileName !in textureSet)
      textureSet[fileName] = Texture2D.from_image(fileName);

    auto component = new Sprite(entity.get!double("size"), fileName, textureSet[fileName]);

    component.position = entity.get!vec3("position");
    component.angle = entity.get!double("angle");

    return component;
  }

  override void updateValues()
  {
    StopWatch debugTimer;
    debugTimer.start;
    vertices = null;
    texCoords = null;
    colors = null;

    foreach (component; components)
    {
      auto transform = (vec3 vertex) => (vertex * mat3.zrotation(-component.angle) +
                                         component.position);

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
    foreach (index, entity; entityForIndex)
    {
      components[index].position = entity.get!vec3("position");
      components[index].angle = entity.get!double("angle");
    }
  }

  vec3[][string] vertices;
  vec2[][string] texCoords;
  vec4[][string] colors;
  Texture2D[string] textureSet;
}
