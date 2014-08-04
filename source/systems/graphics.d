module systems.graphics;

import std.algorithm;
import std.array;
import std.datetime;
import std.stdio;

import glamour.texture;
import gl3n.linalg; 

import components.collider;
import components.drawables.polygon;
import components.drawables.text;
import entity;
import system;
import textrenderer.textrenderer;
import textrenderer.transform;


class Graphics : System!bool
{
  this(int xres, int yres)
  {
    this.xres = xres; this.yres = yres;
    textRenderer = new TextRenderer();
    textureSet["text"] = textRenderer.atlas;
  }
  
  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.vectors && "angle" in entity.scalars && 
           (entity.polygon !is null || entity.text !is null || entity.sprite !is null);
  }
  
  override bool makeComponent(Entity entity)
  {
    if (entity.sprite !is null)
      textureSet[entity.sprite.fileName] = entity.sprite.texture;
    return true;
  }
  
  override void update()
  {
    StopWatch debugTimer;
    debugTimer.start;
    vertices = texCoords = null;
    colors = null;
    
    foreach (int index, Entity entity; entityForIndex)
    {
      auto transform = delegate (vec2 vertex) => ((vec3(vertex, 0.0) * 
                                                 mat3.zrotation(-entity.scalars["angle"])).xy + 
                                                 entity.vectors["position"] - cameraPosition) *
                                                 zoom;
      if (entity.polygon !is null)
      {
        // map with delegate in a variable and then array crashes with release build
        //vertices["polygon"] ~= entity.polygon.vertices.map!transform.array();
        auto transformedVertices = entity.polygon.vertices.map!transform;
        foreach (transformedVertex; transformedVertices)
          vertices["polygon"] ~= transformedVertex;
        
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
      else if (entity.sprite !is null)
      {
        auto transformedVertices = entity.sprite.vertices.map!transform;
        foreach (transformedVertex; transformedVertices)
          vertices[entity.sprite.fileName] ~= transformedVertex;
        
        texCoords[entity.sprite.fileName] ~= entity.sprite.texCoords;
      }
    }
    debugText = format("graphics timings: %s", debugTimer.peek.usecs*0.001);
  }
  
  vec2 getWorldPositionFromScreenCoordinates(vec2 screenCoordinates)
  {
    return vec2(screenCoordinates.x / cast(float)xres - 0.5, 
                0.5 - screenCoordinates.y / cast(float)yres) * (1.0 / zoom) * 2.0;
  }
  
  immutable int xres, yres;
  TextRenderer textRenderer;
  vec2 cameraPosition = vec2(0.0, 0.0);
  float zoom = 0.3;
  vec2[][string] vertices, texCoords;
  vec4[][string] colors;
  Texture2D[string] textureSet;
}
