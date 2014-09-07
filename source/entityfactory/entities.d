module entityfactory.entities;

import std.algorithm;
import std.file;
import std.random;
import std.range;
import std.stdio;

import gl3n.linalg;

import components.collider;
import components.drawables.polygon;
import components.drawables.sprite;
import components.drawables.text;
import components.input;
import components.sound;
import entity;


Entity createGameController()
{
  auto gameController = new Entity();
  gameController.values["input"] = "gameControls"; //Input.gameControls.to!string; // = new Input(Input.gameControls);
  return gameController;
}

Entity createEditController()
{
  auto editController = new Entity();
  editController.values["input"] = "textInput"; // Input.textInput.to!string; //new Input(Input.textInput);
  return editController;
}

Entity createPlayer()
{
  auto playerEntity = createEntity(vec2(0.0, 0.0), vec2(0.0, 0.0), 0.3);
  
  playerEntity.values["input"] = "playerInput"; //Input.playerInput.to!string;
  playerEntity.values["angle"] = 0.0.to!string;
  playerEntity.values["sprite"] = "images/playerShip1_blue.png";
  playerEntity.values["collider"] = ColliderType.Player.to!string;
  
  return playerEntity;
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
  
  auto files = dirEntries("images", "*.png", SpanMode.breadth).
               map!(dirEntry => dirEntry.name).array();
  
  if (!files.empty)
    entity.values["sprite"] = files.randomSample(1).front;
  
  return entity;
}

Entity[] createEntities(uint elements)
{
  Entity[] entities;
  foreach (double index; iota(0, elements))
  {
    auto angle = (index/elements) * PI * 2.0;
    auto size = uniform(0.025, 0.125);
    auto position = vec2(uniform(-5.0, 5.0), uniform(-5.0, 5.0));                   
    auto entity = createEntity(position, vec2(cos(angle) * 0.5, sin(angle) * 0.5),
                               size);
    entities ~= entity;
  }
  return entities;
}

Entity createBullet(vec2 position, float angle, vec2 velocity, double lifeTime)
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

  return entity;
}
