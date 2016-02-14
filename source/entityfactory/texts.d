module entityfactory.texts;

import std.conv;
import std.range;

import gl3n.aabb;
import gl3n.linalg;

import components.collider;
import components.drawables.polygon;
import entity;


Entity createText(string text, vec3 position)
{
  auto textEntity = new Entity();
  
  textEntity["position"] = position;
  //textEntity["velocity"] = vec3(0.0, 0.1, 0.0);
  //textEntity["mass"] = 1000.1;
  textEntity["angle"] = 0.0;
  textEntity["size"] = 0.1;
  textEntity["graphicsource"] = "text";
  textEntity["text"] = text;
  textEntity["color"] = vec4(1.0, 1.0, 1.0, 0.0);
  textEntity["collider"] = ColliderType.GuiElement;
  
  return textEntity;
}

Entity createTextCover(Entity textEntity, AABB textAABB)
{
  auto textCover = new Entity();
  auto position = textEntity.get!vec3("position");
  //position.z -= 1.0;
  textCover["position"] = position;
  textCover["angle"] = 0.0.to!string;
  textCover["size"] = textAABB.extent.magnitude;
  
  textCover["graphicsource"] = "polygon";  
  auto polygon = new Polygon([vec3(textAABB.min.x, textAABB.min.y, 0.0), 
                              vec3(textAABB.min.x, textAABB.max.y, 0.0), 
                              vec3(textAABB.max.x, textAABB.min.y, 0.0), 
                              vec3(textAABB.min.x, textAABB.max.y, 0.0), 
                              vec3(textAABB.max.x, textAABB.max.y, 0.0), 
                              vec3(textAABB.max.x, textAABB.min.y, 0.0)],
                              vec4(0.0, 0.5, 0.5, 0.5).repeat.take(6).array);
  textCover["polygon.vertices"] = polygon.vertices;
  textCover["polygon.colors"] = polygon.colors;
  
  textCover["relation.types"] = ["RelativeValues", "SameShape", "DieTogether"];
  textCover["relation.targetId"] = textEntity.id;
  textCover["relation.value.position"] = vec3(0.0, 0.0, 0.0);
  
  return textCover;
}
