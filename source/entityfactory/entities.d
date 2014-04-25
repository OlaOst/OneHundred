module entityfactory.entities;

import std.algorithm;
import std.file;
import std.random;
import std.range;
import std.stdio;

import gl3n.linalg;

import component.collider;
import component.drawables.polygon;
import component.drawables.sprite;
import component.drawables.text;
import component.input;
import component.sound;
import entity;


Entity createGameController()
{
  auto gameController = new Entity();
  
  gameController.input = new Input(Input.gameControls);
  
  return gameController;
}

Entity createPlayer()
{
  auto playerEntity = createEntity(vec2(0.0, 0.0), vec2(0.0, 0.0), 0.3, 3, 3);
  
  playerEntity.input = new Input(Input.playerInput);
  
  playerEntity.polygon = null;
  playerEntity.sprite = new Sprite(0.3, "images/playerShip1_blue.png");
  
  return playerEntity;
}

Entity createEntity(vec2 position, vec2 velocity, double size, int minVerts, int maxVerts)
{
  auto entity = new Entity();

  auto drawable = new Polygon(size, 
                              uniform(minVerts, maxVerts+1), 
                              vec4(uniformDistribution!float(3).vec3, 0.5));
  
  entity.vectors["position"] = position;
  entity.vectors["velocity"] = velocity;
  entity.scalars["angle"] = uniform(-PI, PI);
  entity.scalars["size"] = size;
  entity.scalars["mass"] = 0.1 + size ^^ 2;
  //entity.polygon = drawable;
  
  auto files = dirEntries("images", "*.png", SpanMode.breadth).
               map!(dirEntry => dirEntry.name).array();
  
  entity.sprite = new Sprite(size, files.randomSample(1).front);
  
  auto colliderVertices = chain(drawable.vertices[1..$].stride(3), 
                                drawable.vertices[2..$].stride(3)).
                          map!(vertex => vertex + position).array;
  
  entity.collider = new Collider(drawable.vertices);
  
  return entity;
}

Entity[] createEntities(uint elements)
{
  Entity[] entities;
  foreach (double index; iota(0, elements))
  {
    auto angle = (index/elements) * PI * 2.0;
    auto size = uniform(0.025, 0.125);
    //auto position = vec2(1.0 + cos(angle * 5) * (0.3 + angle.sqrt),
                         //sin(angle * 5) * (0.3 + angle.sqrt));
    auto position = vec2(uniform(-5.0, 5.0), uniform(-5.0, 5.0));                   
    auto entity = createEntity(position,
                               vec2(sin(angle) * 0.5, cos(angle) * 0.5),
                               size,
                               3, 12);
    entities ~= entity;
  }
  return entities;
}
