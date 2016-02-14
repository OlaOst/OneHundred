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
import entityfactory.entitycollection;
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

/*Entity[] createNpcEntityGroup()
{
  auto npcEntityGroup = "data/npcship.txt".createEntityCollectionFromFile;
    
  npcEntityGroup.values.each!(entity => entity.get!string("fullName").writeln);
    
  return npcEntityGroup.values;
}*/

Entity[string] createBulletEntityGroup(vec3 position, double angle, vec3 velocity, 
                                 double lifeTime, const long spawnerId)
{
  auto bulletEntityGroup = "data/bullet.txt".createEntityCollectionFromFile;

  foreach (bulletEntity; bulletEntityGroup)
  {
    bulletEntity["position"] = position;
    bulletEntity["angle"] = angle;
    bulletEntity["velocity"] = velocity;
    bulletEntity["spawner"] = spawnerId;
    bulletEntity["networked"] = true;
    
    import systems.polygongraphics;
    //bulletEntity.polygon = parsePolygonFromEntity(bulletEntity);
    auto polygon = parsePolygonFromEntity(bulletEntity);
    bulletEntity["polygon.vertices"] = polygon.vertices;
    bulletEntity["polygon.colors"] = polygon.colors;
  }
  
  return bulletEntityGroup;
}

Polygon parsePolygonFromEntity(Entity entity)
{
  assert(entity.has("polygon.vertices"));
  assert(entity.has("polygon.colors") || entity.has("color"));
 
  auto vertices = entity.get!(vec3[])("polygon.vertices");
  
  vec4[] colors;
  if (entity.has("polygon.colors"))
    colors = entity.get!(vec4[])("polygon.colors");
  else
    colors = entity.get!vec4("color").repeat(colors.length).array;
    
  assert(vertices.length == colors.length);
  return new Polygon(vertices, colors);
}
