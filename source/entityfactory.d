module entityfactory;

import std.random;

import artemisd.all;
import gl3n.linalg;

import component.drawable;
import component.input;
import component.mass;
import component.position;
import component.size;
import component.velocity;


Entity createGameController(World world)
{
  Entity gameController = world.createEntity();
  
  gameController.addComponent(new Input(Input.gameControls));
  
  return gameController;
}

Entity createPlayer(World world)
{
  Entity playerEntity = world.createEntity();
  
  playerEntity.addComponent(new Position(vec2(0.0, 0.0), 0.0));
  playerEntity.addComponent(new Velocity(vec2(0.0, 0.0), 0.0));
  playerEntity.addComponent(new Size(0.3));
  playerEntity.addComponent(new Mass(0.3 ^^ 2));
  playerEntity.addComponent(new Drawable(0.3, 3, vec3(0.0, 1.0, 0.0)));
  playerEntity.addComponent(new Input(Input.playerInput));
  
  return playerEntity;
}

Entity createEntity(World world, vec2 position, vec2 velocity, double size)
{
  Entity entity = world.createEntity();
    
  entity.addComponent(new Position(position, 0.0));
  entity.addComponent(new Velocity(velocity, uniform(-PI, PI)));
  entity.addComponent(new Size(size));
  entity.addComponent(new Mass(0.1 + size ^^ 2));
  entity.addComponent(new Drawable(size, uniform(3, 12), uniformDistribution!float(3).vec3));
  
  return entity;
}
