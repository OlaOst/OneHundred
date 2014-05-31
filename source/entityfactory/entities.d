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
  gameController.input = new Input(Input.gameControls);
  return gameController;
}

Entity createEditController()
{
  auto editController = new Entity();
  editController.input = new Input(Input.textInput);
  return editController;
}

Entity createPlayer()
{
  auto playerEntity = createEntity(vec2(0.0, 0.0), vec2(0.0, 0.0), 0.3);
  
  playerEntity.input = new Input(Input.playerInput);
  playerEntity.scalars["angle"] = 0.0;
  playerEntity.polygon = null;
  playerEntity.sprite = new Sprite(0.3, "images/playerShip1_blue.png");
  
  playerEntity.collider.type = ColliderType.Player;
  
  return playerEntity;
}

Entity createEntity(vec2 position, vec2 velocity, double size)
{
  auto entity = new Entity();

  auto drawable = new Polygon(size, uniform(4, 4+1), 
                              vec4(uniformDistribution!float(3).vec3, 0.5));
  
  entity.vectors["position"] = position;
  entity.vectors["velocity"] = velocity;
  entity.scalars["angle"] = uniform(-PI, PI);
  entity.scalars["size"] = size;
  entity.scalars["mass"] = 0.1 + size ^^ 2;
  
  auto files = dirEntries("images", "*.png", SpanMode.breadth).
               map!(dirEntry => dirEntry.name).array();
  
  if (!files.empty)
    entity.sprite = new Sprite(size, files.randomSample(1).front);
  
  entity.collider = new Collider(drawable.vertices, ColliderType.Npc);
  
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
    auto entity = createEntity(position, vec2(sin(angle) * 0.5, cos(angle) * 0.5),
                               size);
    entities ~= entity;
  }
  return entities;
}

Entity createBullet(vec2 position, float angle, vec2 velocity, double lifeTime)
{
  auto entity = createEntity(position, velocity + vec2(sin(-angle), cos(-angle)) * 5.0, 0.1);
  entity.scalars["angle"] = angle + PI/2;
  entity.scalars["lifeTime"] = lifeTime;
  entity.sprite = null;
  entity.polygon = new Polygon(0.1, uniform(3, 4), 
                               vec4(uniformDistribution!float(3).vec3, 0.5));

  entity.collider.type = ColliderType.Bullet;
  return entity;
}
