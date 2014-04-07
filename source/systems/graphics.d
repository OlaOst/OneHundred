module systems.graphics;

import std.algorithm;
import std.array;
import std.stdio;

import gl3n.linalg; 

import component.collider;
import component.drawables.polygon;
import component.drawables.text;
import entity;
import system;
import textrenderer.textrenderer;
import textrenderer.transform;


class Graphics : System
{
  this(int xres, int yres)
  {
    this.xres = xres; this.yres = yres;
    textRenderer = new TextRenderer();
  }
  
  void close() { textRenderer.close(); }
  
  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.vectors && (entity.polygon !is null || entity.text !is null);
  }
  
  override void addEntity(Entity entity)
  {
    if (canAddEntity(entity))
    {
      indexForEntity[entity] = positions.length;
      entityForIndex[positions.length] = entity;
      positions ~= entity.vectors["position"];
      "angle" in entity.scalars ? angles ~= entity.scalars["angle"] : angles ~= 0.0;
    }
  }
  
  override void update()
  {
    vertices = null;
    colors = null;
    texCoords = null;
    
    foreach (int index, Entity entity; entityForIndex)
    {
      auto transform = delegate (vec2 vertex) => ((vec3(vertex, 0.0) * 
                                                 mat3.zrotation(angles[index])).xy + 
                                                 positions[index] - cameraPosition) *
                                                 zoom;
      if (entity.polygon !is null)
      {
        vertices["polygon"] ~= entity.polygon.vertices.map!transform.array();
        if (entity.collider !is null && entity.collider.isColliding)
          colors["polygon"] ~= entity.polygon.colors.map!(color => vec4(1.0, color.gba)).array;
        else
          colors["polygon"] ~= entity.polygon.colors;
      }
      else if (entity.text !is null)
      {
        texCoords["text"] ~= textRenderer.getTexCoordsForText(entity.text);
        vertices["text"] ~= textRenderer.getVerticesForText(entity.text, zoom, transform);
      }
    }
  }
  
  void updateFromEntities()
  {
    foreach (int index, Entity entity; entityForIndex)
    {
      positions[index] = entity.vectors["position"];
      angles[index] = "angle" in entity.scalars ? entity.scalars["angle"] : 0.0;
    }
  }
  
  vec2 getWorldPositionFromScreenCoordinates(vec2 screenCoordinates)
  {
    return vec2(screenCoordinates.x / cast(float)xres - 0.5, 
                0.5 - screenCoordinates.y / cast(float)yres) * (1.0 / zoom) * 2.0;
  }
  
public:
  vec2 cameraPosition = vec2(0.0, 0.0);
  float zoom = 0.3;
  vec2[][string] vertices, texCoords;
  vec4[][string] colors;
  
private:
  int xres, yres;
  TextRenderer textRenderer;
  vec2[] positions;
  double[] angles;
}
