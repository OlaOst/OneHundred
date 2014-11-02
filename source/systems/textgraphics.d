module systems.textgraphics;

import std.algorithm;
import std.array;
import std.datetime;
import std.stdio;

import glamour.texture;
import gl3n.linalg; 

import camera;
import components.collider;
import components.drawables.text;
import converters;
import entity;
import system;
import textrenderer.textrenderer;
import textrenderer.transform;


class TextGraphics : System!Text
{
  this(int xres, int yres, Camera camera)
  {
    this.xres = xres; this.yres = yres;
    this.camera = camera;
    textRenderer = new TextRenderer();
    textureSet["text"] = textRenderer.atlas;
  }
  
  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.values && "angle" in entity.values && 
           Text.canMakeComponent(entity.values);
  }
  
  override Text makeComponent(Entity entity)
  {
    Text component = new Text(entity.values["size"].to!double, 
                              entity.values["text"], 
                              entity.values["color"].myTo!vec4);
    
    component.position = vec2(entity.values["position"].to!(float[2]));
    component.angle = entity.values["angle"].to!double;
    
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
      
      {
        texCoords["text"] ~= textRenderer.getTexCoordsForText(component);
        vertices["text"] ~= textRenderer.getVerticesForText(component, camera.zoom, transform);
      }
    }
    debugText = format("textgraphics timings: %s", debugTimer.peek.usecs*0.001);
  }
  
  override void updateEntities()
  {
  }
  
  override void updateFromEntities()
  {
    foreach (int index, Entity entity; entityForIndex)
    {
      //currentStates[index].velocity = entity.vectors["velocity"];
      components[index].position = entity.values["position"].myTo!vec2;
      components[index].angle = entity.values["angle"].to!double;
      
      if (components[index].text !is null)
        components[index].text = entity.values["text"];
    }
  }
  
  
  immutable int xres, yres;
  TextRenderer textRenderer;
  Camera camera;
  vec2[][string] vertices, texCoords;
  vec4[][string] colors;
  Texture2D[string] textureSet;
}
