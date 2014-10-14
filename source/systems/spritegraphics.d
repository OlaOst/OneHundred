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


class SpriteGraphics : System!Sprite
{
  this(int xres, int yres, Camera camera)
  {
    this.xres = xres; this.yres = yres;
    this.camera = camera;
  }
  
  override bool canAddEntity(Entity entity)
  {
    return "position" in entity.values && "angle" in entity.values && 
           Sprite.canMakeComponent(entity.values);
  }
  
  override Sprite makeComponent(Entity entity)
  {
    assert(canAddEntity(entity));
    
    auto component = new Sprite(entity.values["size"].to!double, entity.values["sprite"]);
    
    textureSet[entity.values["sprite"]] = component.texture;
    
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
      auto transform = (vec2 vertex) => ((vec3(vertex, 0.0) * mat3.zrotation(-component.angle)).xy + 
                                                  component.position - camera.position) *
                                                  camera.zoom;

      // map with delegate in a variable and then array crashes with release build in dmd 2.066
      vertices[component.fileName] ~= component.vertices.map!transform.array;
      texCoords[component.fileName] ~= component.texCoords;
    }
    debugText = format("spritegraphics timings: %s", debugTimer.peek.usecs*0.001);
  }
  
  override void updateEntities()
  {
  }
  
  override void updateFromEntities()
  {
    foreach (int index, Entity entity; entityForIndex)
    {
      //currentStates[index].velocity = entity.vectors["velocity"];
      components[index].position = vec2(entity.values["position"].to!(float[2]));
      components[index].angle = entity.values["angle"].to!double;
    }
  }
  
  
  immutable int xres, yres;
  Camera camera;
  vec2[][string] vertices, texCoords;
  vec4[][string] colors;
  Texture2D[string] textureSet;
}
