module systems.textgraphics;

import std.algorithm;
import std.datetime;
import std.range;
import std.stdio;

import glamour.texture;
import gl3n.aabb;
import gl3n.linalg;

import components.drawables.text;
import entity;
import systems.graphics;
import textrenderer.textrenderer;
import textrenderer.transform;


class TextGraphics : Graphics!Text
{
  this(int xres, int yres)
  {
    super(xres, yres);
    textRenderer = new TextRenderer();
  }

  override void close()
  {
    super.close();
    textRenderer.close();
  }

  bool canAddEntity(Entity entity)
  {
    return entity.has("position") && entity.has("text");
  }

  Text makeComponent(Entity entity)
  {
    Text component = new Text(entity.get!double("size", 1.0),
                              entity.get!string("text"),
                              entity.get!vec4("color", vec4(1.0, 1.0, 1.0, 1.0)));
    component.position = entity.get!vec3("position");
    component.angle = entity.get!double("angle");
    //auto textVertices = textRenderer.getVerticesForText(component);
    //component.aabb = AABB.from_points(textVertices);
    entity["aabb"] = [component.aabb.min, component.aabb.max];
    return component;
  }

  void updateValues() //@nogc
  {
    vertices = null;
    texCoords = null;
    colors = null;
    size_t texCoordIndex, verticesIndex, colorIndex;
    foreach (component; components)
    {
      //auto texCoords = textRenderer.getTexCoordsForText(component);
      //auto vertices = textRenderer.getVerticesForText(component);
      //texCoordBuffer.fillBuffer(texCoords, texCoordIndex);
      //verticesBuffer.fillBuffer(vertices, verticesIndex);
      //colorBuffer.fillBuffer(component.color.repeat.take(texCoords.length).array, colorIndex);
      //component.aabb = AABB.from_points(vertices);
    }
    texCoords["text"] = texCoordBuffer[0 .. texCoordIndex];
    vertices["text"] = verticesBuffer[0 .. verticesIndex];
    colors["text"] = colorBuffer[0 .. colorIndex];
  }

  void updateEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      auto relativePosition = -components[index].position;
      entity["aabb"] = [components[index].aabb.min + relativePosition,
                        components[index].aabb.max + relativePosition];
    }
  }

  void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      components[index].position = entity.get!vec3("position");
      components[index].angle = entity.get!double("angle");
      if (components[index].text !is null)
        components[index].text = entity.get!string("text");
    }
  }

  TextRenderer textRenderer;
}
