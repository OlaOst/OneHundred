module entityfactory.tests;

import std.algorithm;
import std.random;
import std.range;
import std.stdio;

import gl3n.linalg;

import components.collider;
import components.drawables.polygon;
import components.drawables.text;
import components.sound;
import entity;
import entityfactory.texts;
import systemset;


Entity createMusic()
{
  auto entity = new Entity();
  entity["position"] = vec3(300.0, 0.0, 0.0);
  entity["velocity"] = vec3(0.0, 3.0, 0.0);
  entity["size"] = 0.1;
  entity["mass"] = (0.1 + 0.1 ^^ 2);
  entity["sound"] = "audio/orbitalelevator.ogg";
  
  return entity;
}

Entity createStartupSound()
{
  auto startupSound = new Entity();
  startupSound["sound"] = "audio/gasturbinestartup.ogg";
  
  return startupSound;
}

Entity createMouseCursor()
{
  float size = 0.1;
  auto position = vec3(0.0, 0.0, 0.0);
  auto mouseCursor = new Entity();
  mouseCursor["position"] = position;
  mouseCursor["angle"] = 0.0;
  
  auto drawable = new Polygon(size, 3, vec4(1.0, 0.0, 0.0, 0.0));
  //mouseCursor["polygon.vertices"] = drawable.vertices;
  //mouseCursor["polygon.colors"] = drawable.colors;
  mouseCursor.polygon = drawable;
  
  auto colliderVertices = chain(drawable.vertices[1..$].stride(3), 
                                drawable.vertices[2..$].stride(3)).
                          map!(vertex => vertex + position).array;
  
  mouseCursor["collider"] = ColliderType.Cursor;
  mouseCursor["collider.vertices"] = colliderVertices;
  
  return mouseCursor;
}

void addDebugEntities(SystemSet systemSet)
{
  foreach (index, entityHandler; systemSet.entityHandlers)
  {
    auto position = vec3(-3.0, index*0.7 - 4, 0.0);
    
    auto text = new Entity();
    text["position"] = vec3(position.x + 0.35, position.y, 0.0);
    text["text"] = entityHandler.className;
    text["color"] = vec4(1.0, 1.0, 1.0, 1.0);
    text["size"] = 0.1;
    systemSet.addEntity(text);
    systemSet.addEntity(text.createTextCover(systemSet.textGraphics.getComponent(text).aabb));
    
    auto debugEntity = new Entity();
    debugEntity["position"] = position;
    debugEntity["size"] = 0.3;
    auto polygon = new Polygon(0.25, 16, vec4(0.0, 0.67, 0.33, 1.0));
    //debugEntity["polygon.vertices"] = polygon.vertices;
    //debugEntity["polygon.colors"] = polygon.colors;
    debugEntity.polygon = polygon;
    debugEntity["name"] = entityHandler.className;
    debugEntity["collider"] = ColliderType.GuiElement;
    systemSet.addEntity(debugEntity);
  }
}
