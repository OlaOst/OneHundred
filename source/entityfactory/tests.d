module entityfactory.tests;

import std.algorithm;
import std.random;
import std.range;
import std.stdio;

import gl3n.linalg;

import component.collider;
import component.drawables.polygon;
import component.drawables.text;
import component.sound;
import entity;


Entity createMusic()
{
  auto entity = new Entity();
  entity.vectors["position"] = vec2(300.0, 0.0);
  entity.vectors["velocity"] = vec2(0.0, 3.0);
  entity.scalars["size"] = 0.1;
  entity.scalars["mass"] = 0.1 + 0.1 ^^ 2;  
  entity.sound = new Sound("audio/orbitalelevator.ogg");
  
  return entity;
}

Entity createStartupSound()
{
  auto startupSound = new Entity();
  startupSound.sound = new Sound("audio/gasturbinestartup.ogg");
  
  return startupSound;
}

Entity createText()
{
  auto text = new Entity();
  
  text.vectors["position"] = vec2(-1.0, 0.0);
  text.scalars["angle"] = 0.0;
  text.scalars["size"] = 0.1;
  text.text = new Text(0.1, "hello,\n world", vec4(1.0, 1.0, 0.5, 0.0));
  
  return text;
}

Entity createDebugText()
{
  auto text = new Entity();
  
  text.vectors["position"] = vec2(-3.0, -2.0);
  text.scalars["angle"] = 0.0;
  text.scalars["size"] = 0.1;
  text.text = new Text(0.1, "??", vec4(1.0, 0.5, 0.5, 0.0));
  
  return text;
}

Entity createMouseCursor()
{
  float size = 0.1;
  auto position = vec2(0.0, 0.0);
  auto mouseCursor = new Entity();
  mouseCursor.vectors["position"] = position;
  mouseCursor.scalars["angle"] = 0.0;
  
  auto drawable = new Polygon(size, 3, vec4(1.0, 0.0, 0.0, 0.0));
  mouseCursor.polygon = drawable;
  
  auto colliderVertices = chain(drawable.vertices[1..$].stride(3), 
                                drawable.vertices[2..$].stride(3)).
                          map!(vertex => vertex + position).array;
  
  mouseCursor.collider = new Collider(colliderVertices);
  
  return mouseCursor;
}
