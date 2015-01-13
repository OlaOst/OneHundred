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

Entity createEntity(vec2 position, vec2 velocity, double size)
{
  auto entity = new Entity();

  auto drawable = new Polygon(size, uniform(4, 4+1), 
                              vec4(uniformDistribution!float(3).vec3, 0.5));
  
  entity.values["position"] = position.to!string;
  entity.values["velocity"] = velocity.to!string;
  entity.values["angle"] = uniform(-PI, PI).to!string;
  entity.values["size"] = size.to!string;
  entity.values["mass"] = (0.1 + size ^^ 2).to!string;
  entity.values["collider"] = ColliderType.Npc.to!string;

  return entity;
}

Entity[] createNpcs(uint elements)
{
  Entity[] entities;
  
  foreach (index; iota(0, elements))
    entities ~= "data/npc.txt".createEntityFromFile;
    
  return entities;
}

Entity createBullet(vec2 position, float angle, vec2 velocity, 
                    double lifeTime, const long spawnerId)
{
  auto entity = createEntity(position, velocity, 0.1);
  
  auto color = vec4(uniformDistribution!float(3).vec3, 0.5);
  
  entity.values["angle"] = angle.to!string;
  entity.values["lifeTime"] = lifeTime.to!string;
  
  auto polygon = new Polygon(0.1, uniform(3, 4), 
                             vec4(uniformDistribution!float(3).vec3, 0.5));
  
  entity.values["polygon.vertices"] = polygon.vertices.to!string;
  entity.values["polygon.colors"] = polygon.colors.to!string;
  entity.values["collider"] = ColliderType.Bullet.to!string;

  entity.values["spawner"] = spawnerId.to!string;
  
  return entity;
}
