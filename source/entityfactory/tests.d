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
import systemset;


Entity createMusic()
{
  auto entity = new Entity();
  entity.values["position"] = vec2(300.0, 0.0).to!string;
  entity.values["velocity"] = vec2(0.0, 3.0).to!string;
  entity.values["size"] = 0.1.to!string;
  entity.values["mass"] = (0.1 + 0.1 ^^ 2).to!string;
  entity.values["sound"] = "audio/orbitalelevator.ogg";
  
  return entity;
}

Entity createStartupSound()
{
  auto startupSound = new Entity();
  startupSound.values["sound"] = "audio/gasturbinestartup.ogg";
  
  return startupSound;
}

Entity createMouseCursor()
{
  float size = 0.1;
  auto position = vec2(0.0, 0.0);
  auto mouseCursor = new Entity();
  mouseCursor.values["position"] = position.to!string;
  mouseCursor.values["angle"] = 0.0.to!string;
  
  auto drawable = new Polygon(size, 3, vec4(1.0, 0.0, 0.0, 0.0));
  mouseCursor.values["polygon.vertices"] = drawable.vertices.to!string;
  mouseCursor.values["polygon.colors"] = drawable.colors.to!string;
  
  auto colliderVertices = chain(drawable.vertices[1..$].stride(3), 
                                drawable.vertices[2..$].stride(3)).
                          map!(vertex => vertex + position).array;
  
  mouseCursor.values["collider"] = ColliderType.Cursor.to!string;
  mouseCursor.values["collider.vertices"] = colliderVertices.to!string;
  
  return mouseCursor;
}

void addDebugEntities(SystemSet systemSet)
{
  foreach (index, entityHandler; systemSet.entityHandlers)
  {
    auto position = vec2(-3.0, index*0.7 - 4);
    
    auto text = new Entity();
    text.values["position"] = vec2(position.x + 0.35, position.y).to!string;
    text.values["text"] = entityHandler.className;
    text.values["color"] = vec4(1.0, 1.0, 1.0, 1.0).to!string;
    text.values["size"] = 0.1.to!string;
    systemSet.addEntity(text);
    
    auto debugEntity = new Entity();
    debugEntity.values["position"] = position.to!string;
    debugEntity.values["size"] = 0.3.to!string;
    auto polygon = new Polygon(0.25, 16, vec4(0.0, 0.67, 0.33, 1.0));
    debugEntity.values["polygon.vertices"] = polygon.vertices.to!string;
    debugEntity.values["polygon.colors"] = polygon.colors.to!string;
    debugEntity.values["name"] = entityHandler.className;
    systemSet.addEntity(debugEntity);
  }
}
