module systems.textgraphics;

import std.datetime;
import std.range;
import std.stdio;

import glamour.texture;
import gl3n.aabb;
import gl3n.linalg;

import camera;
import components.drawables.text;
import entity;
import systems.graphics;
import textrenderer.textrenderer;
import textrenderer.transform;


class TextGraphics : Graphics!Text
{
  this(int xres, int yres, Camera camera)
  {
    super(xres, yres, camera);
    textRenderer = new TextRenderer();
    textureSet["text"] = textRenderer.atlas;
  }
  
  ~this()
  {
    foreach (name, texture; textureSet)
      texture.remove();
  }

  override bool canAddEntity(Entity entity)
  {
    return entity.has("position") && entity.has("text") && 
           entity.has("size") && entity.has("color");
  }

  override Text makeComponent(Entity entity)
  {
    Text component = new Text(entity.get!double("size"),
                              entity.get!string("text"),
                              entity.get!vec4("color"));
    component.position = entity.get!vec3("position");
    component.angle = entity.get!double("angle");
    auto textVertices = textRenderer.getVerticesForText(component, camera);
    component.aabb = AABB.from_points(textVertices);
    entity["aabb"] = [component.aabb.min, component.aabb.max];
    return component;
  }

  override void updateValues() //@nogc
  {
    vertices = null;
    texCoords = null;
    colors = null;
    
    size_t texCoordIndex, verticesIndex, colorIndex;
    foreach (component; components)
    {
      auto texCoords = textRenderer.getTexCoordsForText(component);
      auto vertices = textRenderer.getVerticesForText(component, camera);
      texCoordBuffer.fillBuffer(texCoords, texCoordIndex);
      verticesBuffer.fillBuffer(vertices, verticesIndex);
      colorBuffer[colorIndex .. colorIndex + texCoords.length] = component.color;
      colorIndex += texCoords.length;
      component.aabb = AABB.from_points(vertices);
    }
    texCoords["text"] = texCoordBuffer[0 .. texCoordIndex];
    vertices["text"] = verticesBuffer[0 .. verticesIndex];
    colors["text"] = colorBuffer[0 .. colorIndex];
  }
  
  override void updateEntities() 
  {
    foreach (index, entity; entityForIndex)
    {
      auto relativePosition = camera.position - components[index].position;
      entity["aabb"] = [components[index].aabb.min * (1.0/camera.zoom) + relativePosition,
                        components[index].aabb.max * (1.0/camera.zoom) + relativePosition];
    }
  }

  override void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      components[index].position = entity.get!vec3("position");
      components[index].angle = entity.get!double("angle");
      if (components[index].text !is null)
        components[index].text = entity.get!string("text");
    }   
  }

  vec3[65536] verticesBuffer;
  vec2[65536] texCoordBuffer;
  vec4[65536] colorBuffer;
  
  TextRenderer textRenderer;
  vec3[][string] vertices;
  vec2[][string] texCoords;
  vec4[][string] colors;
  Texture2D[string] textureSet;
}
