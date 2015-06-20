module entityfactory.entities;

import std.algorithm;
import std.file;
import std.random;
import std.range;
import std.stdio;
import std.string;

import gl3n.linalg;

import components.collider;
import components.drawables.polygon;
import components.drawables.sprite;
import components.drawables.text;
import components.input;
import components.sound;
import converters;
import entity;
import valueparser;


Entity createEntityFromFile(string file)
{
  string[string] values;
  foreach (keyvalue; file.File.byLine.map!(line => line.strip)
                                     .filter!(line => !line.empty)
                                     .filter!(line => !line.startsWith("#"))
                                     .map!(line => line.split("=")))
  {
    auto key = keyvalue[0].strip.to!string;
    auto value = keyvalue[1].strip.to!string;
    values[key] = value.parseValue(key);
  }
  return new Entity(values);
}

Entity createEntity(vec3 position, vec3 velocity, double size)
{
  auto entity = new Entity();

  auto drawable = new Polygon(size, uniform(4, 4+1), 
                              vec4(uniformDistribution!float(3).vec3, 0.5));
  
  entity["position"] = position;
  entity["velocity"] = velocity;
  entity["angle"] = uniform(-PI, PI);
  entity["size"] = size;
  entity["mass"] = (0.1 + size ^^ 2);
  entity["collider"] = ColliderType.Npc;

  return entity;
}

Entity[] createNpcs(uint elements)
{
  Entity[] entities;
  
  foreach (index; iota(0, elements))
    entities ~= "data/npc.txt".createEntityFromFile;
    
  return entities;
}

Entity createBullet(vec3 position, double angle, vec3 velocity, 
                    double lifeTime, const long spawnerId)
{
  auto entity = createEntity(position, velocity, 0.1);
  
  auto color = vec4(uniformDistribution!float(3).vec3, 0.5);
  
  entity["angle"] = angle;
  entity["lifeTime"] = lifeTime;
  
  auto polygon = new Polygon(0.1, uniform(3, 4), 
                             vec4(uniformDistribution!float(3).vec3, 0.5));
  
  //entity["polygon.vertices"] = polygon.vertices;
  //entity["polygon.colors"] = polygon.colors;
  entity.polygon = polygon;
  entity["collider"] = ColliderType.Bullet;

  entity["collisionfilter"] = "playership.*";
  
  entity["spawner"] = spawnerId;
  
  entity["networked"] = true;
  
  return entity;
}
