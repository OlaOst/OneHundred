module systems.textgraphics;

import std.datetime;
import std.range;

import glamour.texture;
import gl3n.aabb;
import gl3n.linalg;

import camera;
import components.drawables.text;
import converters;
import entity;
import system;
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
    return entity.has("position") && entity.has("text") && entity.has("size") && entity.has("color");
  }

  override Text makeComponent(Entity entity)
  {
    Text component = new Text(entity.get!double("size"),
                              entity.get!string("text"),
                              entity.get!vec4("color"));
    component.position = entity.get!vec2("position");
    component.angle = entity.get!double("angle");
    
    assert(camera !is null);
    auto textVertices = textRenderer.getVerticesForText(component, camera);
    
    component.aabb = AABB.from_points(textVertices.map!(vertex => vec3(vertex, 0.0)).array);
    entity["aabb"] = [component.aabb.min.xy, 
                      component.aabb.max.xy];
                      
    return component;
  }

  override void updateValues() //@nogc
  {
    vertices = texCoords = null;
    colors = null;
    
    static vec2[65536] texCoordBuffer;
    static vec2[65536] verticesBuffer;
    static vec4[65536] colorBuffer;
    
    size_t texCoordIndex = 0;
    size_t verticesIndex = 0;
    size_t colorIndex = 0;
    
    foreach (component; components)
    {
      texCoordIndex += texCoordBuffer.fillBuffer(textRenderer.getTexCoordsForText(component), texCoordIndex);
      verticesIndex += verticesBuffer.fillBuffer(textRenderer.getVerticesForText(component, camera), verticesIndex);
      colorIndex += colorBuffer.fillBuffer(component.color.repeat.take(textRenderer.getTexCoordsForText(component).length).array, colorIndex);
      component.aabb = AABB.from_points(textRenderer.getVerticesForText(component, camera).map!(vertex => vec3(vertex, 0.0)).array);
    }
    
    texCoords["text"] = texCoordBuffer[0 .. texCoordIndex];
    vertices["text"] = verticesBuffer[0 .. verticesIndex];
    colors["text"] = colorBuffer[0 .. colorIndex];
  }
  
  override void updateEntities() 
  {
    foreach (index, entity; entityForIndex)
    {
      entity["aabb"] = [components[index].aabb.min.xy * (1.0/camera.zoom) - components[index].position + camera.position,
                        components[index].aabb.max.xy * (1.0/camera.zoom) - components[index].position + camera.position];
    }
  }

  override void updateFromEntities()
  {
    foreach (index, entity; entityForIndex)
    {
      components[index].position = entity.get!vec2("position");
      components[index].angle = entity.get!double("angle");
      if (components[index].text !is null)
        components[index].text = entity.get!string("text");
    }
  }

  TextRenderer textRenderer;
  vec2[][string] vertices, texCoords;
  vec4[][string] colors;
  Texture2D[string] textureSet;
}
