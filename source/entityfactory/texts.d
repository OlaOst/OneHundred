module entityfactory.texts;

import std.conv;
import std.range;

import gl3n.aabb;
import gl3n.linalg;

import components.collider;
import entity;


Entity createText(string text, vec2 position)
{
  auto textEntity = new Entity();
  
  textEntity.values["position"] = position.to!string;
  //textEntity.values["velocity"] = vec2(0.0, 0.1).to!string;
  //textEntity.values["mass"] = 1000.1.to!string;
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
  
  textCover.values["relation.types"] = ["RelativeValues", "SameShape", "DieTogether"].to!string;
  textCover.values["relation.targetId"] = textEntity.id.to!string;
  textCover.values["relation.value.position"] = vec2(0.0, 0.0).to!string;
  //textCover.values["relation.value.aabb"] = "same";//AABB(vec3(0,0,0),vec3(0,0,0)).to!string;
  
  return textCover;
}
