module entityfactory.tests;

import std.algorithm;
import std.random;
import std.range;
import std.stdio;

import gl3n.aabb;
import gl3n.linalg;

import components.collider;
import components.drawables.polygon;
import components.drawables.text;
import components.sound;
import entity;


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

Entity createText(string text, vec2 position)
{
  auto textEntity = new Entity();
  
  textEntity.values["position"] = position.to!string;
  textEntity.values["velocity"] = vec2(0.0, 0.1).to!string;
  textEntity.values["mass"] = 1000.1.to!string;
  textEntity.values["angle"] = 0.0.to!string;
  textEntity.values["size"] = 0.1.to!string;
  textEntity.values["text"] = text;
  textEntity.values["color"] = vec4(1.0, 1.0, 1.0, 1.0).to!string;
  textEntity.values["collider"] = ColliderType.GuiElement.to!string;
  
  return textEntity;
}

Entity createTextCover(Entity textEntity, AABB textAABB)
{
  auto textCover = new Entity();
  textCover.values["position"] = textEntity.values["position"];
  textCover.values["angle"] = 0.0.to!string;
  textCover.values["polygon.vertices"] = [[textAABB.min.x, textAABB.min.y], 
                                          [textAABB.min.x, textAABB.max.y], 
                                          [textAABB.max.x, textAABB.min.y],
                                          [textAABB.min.x, textAABB.max.y], 
                                          [textAABB.max.x, textAABB.max.y], 
                                          [textAABB.max.x, textAABB.min.y]].to!string;
  textCover.values["polygon.colors"] = [0.0, 0.5, 0.5, 0.5].repeat.take(6).array.to!string;
  
  textCover.values["relation.types"] = ["RelativePosition", "DieTogether"].to!string;
  textCover.values["relation.targetId"] = textEntity.id.to!string;
  //textCover.values["relativePosition"] = vec2(0.0, 0.0);
  
  return textCover;
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
  
  mouseCursor.values["collider"]= ColliderType.Cursor.to!string;
  mouseCursor.values["collider.vertices"] = colliderVertices.to!string;
  
  return mouseCursor;
}
