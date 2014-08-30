module systems.graphics;

import std.algorithm;
import std.array;
import std.datetime;
import std.stdio;

import glamour.texture;
import gl3n.linalg; 

import components.collider;
import components.drawables.polygon;
import components.drawables.sprite;
import components.drawables.text;
import entity;
import system;
import textrenderer.textrenderer;
import textrenderer.transform;


struct GraphicsComponent
{
  vec2 position;
  double angle;
  
  Polygon polygon;
  Text text;
  Sprite sprite;
}

class Graphics : System!GraphicsComponent
{
  this(int xres, int yres)
  {
    this.xres = xres; this.yres = yres;
    textRenderer = new TextRenderer();
    textureSet["text"] = textRenderer.atlas;
  }
  
  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.values && "angle" in entity.values && 
           "polygon.vertices" in entity.values || "text" in entity.values || "sprite" in entity.values;
           //(entity.polygon !is null || entity.text !is null || entity.sprite !is null);
  }
  
  override GraphicsComponent makeComponent(Entity entity)
  {
    GraphicsComponent component;
    
    component.position = vec2(entity.values["position"].to!(float[2]));
    component.angle = entity.values["angle"].to!double;
    
    if (("sprite" in entity.values) !is null)
    {
      component.sprite = new Sprite(entity.values["size"].to!double, entity.values["sprite"]);
      textureSet[entity.values["sprite"]] = component.sprite.texture;
    }
    // TODO: make for polygon and text too
    
    return component;
  }
  
  override void update()
  {
    StopWatch debugTimer;
    debugTimer.start;
    vertices = texCoords = null;
    colors = null;
    
    //foreach (int index, Entity entity; entityForIndex)
    foreach (component; components)
    {
      auto transform = delegate (vec2 vertex) => ((vec3(vertex, 0.0) * mat3.zrotation(-component.angle)).xy + 
                                                  component.position - cameraPosition) *
                                                  zoom;
      if (component.polygon !is null)
      {
        // map with delegate in a variable and then array crashes with release build in dmd 2.065 (and 2.066)
        //vertices["polygon"] ~= component.polygon.vertices.map!transform.array();
        auto transformedVertices = component.polygon.vertices.map!transform;
        foreach (transformedVertex; transformedVertices)
          vertices["polygon"] ~= transformedVertex;
        
        /*if (component.collider !is null && component.collider.isColliding)
          colors["polygon"] ~= component.polygon.colors.map!(color => vec4(1.0, color.gba)).array;
        else*/
          colors["polygon"] ~= component.polygon.colors;
      }
      else if (component.text !is null)
      {
        texCoords["text"] ~= textRenderer.getTexCoordsForText(component.text);
        vertices["text"] ~= textRenderer.getVerticesForText(component.text, zoom, transform);
      }
      else if (component.sprite !is null)
      {
        auto transformedVertices = component.sprite.vertices.map!transform;
        foreach (transformedVertex; transformedVertices)
          vertices[component.sprite.fileName] ~= transformedVertex;
        
        texCoords[component.sprite.fileName] ~= component.sprite.texCoords;
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
