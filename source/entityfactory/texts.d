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
  
  textEntity["position"] = position;
  //textEntity["velocity"] = vec2(0.0, 0.1);
  //textEntity["mass"] = 1000.1;
  textEntity["angle"] = 0.0;
  textEntity["size"] = 0.1;
  textEntity["text"] = text;
  textEntity["color"] = vec4(1.0, 1.0, 1.0, 1.0);
  textEntity["collider"] = ColliderType.GuiElement;
  
  return textEntity;
}

Entity createTextCover(Entity textEntity, AABB textAABB)
{
  auto textCover = new Entity();
  textCover["position"] = textEntity.get!vec2("position");
  textCover["angle"] = 0.0.to!string;
  /*textCover["polygon.vertices"] = [[textAABB.min.x, textAABB.min.y], 
                                   [textAABB.min.x, textAABB.max.y], 
                                   [textAABB.max.x, textAABB.min.y],
                                   [textAABB.min.x, textAABB.max.y], 
                                   [textAABB.max.x, textAABB.max.y], 
                                   [textAABB.max.x, textAABB.min.y]];
  textCover["polygon.colors"] = [0.0, 0.5, 0.5, 0.5].repeat.take(6).array;*/
  import components.drawables.polygon;
  textCover.polygon = new Polygon([vec2(textAABB.min.x, textAABB.min.y), 
                                   vec2(textAABB.min.x, textAABB.max.y), 
                                   vec2(textAABB.max.x, textAABB.min.y),
                                   vec2(textAABB.min.x, textAABB.max.y), 
                                   vec2(textAABB.max.x, textAABB.max.y), 
                                   vec2(textAABB.max.x, textAABB.min.y)],
                                   vec4(0.0, 0.5, 0.5, 0.5).repeat.take(6).array);
  
  textCover["relation.types"] = ["RelativeValues", "SameShape", "DieTogether"];
  textCover["relation.targetId"] = textEntity.id;
  textCover["relation.value.position"] = vec2(0.0, 0.0);
  //textCover["relation.value.aabb"] = "same";//AABB(vec3(0,0,0),vec3(0,0,0));
  
  return textCover;
}
