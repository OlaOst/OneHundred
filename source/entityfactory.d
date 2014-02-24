module entityfactory;

import std.random;
import std.range;
import std.stdio;

import artemisd.all;
import gl3n.linalg;

import component.collider;
import component.drawable;
import component.input;
import component.mass;
import component.position;
import component.size;
import component.sound;
import component.velocity;


Entity createGameController(World world)
{
  Entity gameController = world.createEntity();
  
  gameController.addComponent(new Input(Input.gameControls));
  
  return gameController;
}

Entity createPlayer(World world)
{
  auto playerEntity = createEntity(world, vec2(0.0, 0.0), vec2(0.0, 0.0), 0.3);
  
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
  auto drawable = new Drawable(size, uniform(3, 12), uniformDistribution!float(3).vec3);
  entity.addComponent(drawable);
  
  auto colliderVertices = chain(drawable.vertices[1..$].stride(3), 
                                drawable.vertices[2..$].stride(3)).
                          map!(vertex => vertex + position).array;
  
  entity.addComponent(new Collider(drawable.vertices));
  
  return entity;
}

Entity[] createEntities(World world, uint elements)
{
  Entity[] entities;
  foreach (double index; iota(0, elements))
  {
    auto angle = (index/elements) * PI * 2.0;
    auto size = uniform(0.025, 0.125);
    auto entity = createEntity(world, vec2(1.0 + cos(angle * 5) * (0.3 + angle.sqrt),
                                           sin(angle * 5) * (0.3 + angle.sqrt)),
                                      vec2(sin(angle) * 0.5, cos(angle) * 0.5),
                                      size);
    entities ~= entity;
  }
  return entities;
}

Entity createMusic(World world)
{
  Entity entity = world.createEntity();
  entity.addComponent(new Sound("orbitalelevator.ogg"));
  entity.addComponent(new Position(vec2(300.0, 0.0), 0.0));
  entity.addComponent(new Velocity(vec2(0.0, 3.0), 0.0));
  entity.addComponent(new Size(0.1));
  entity.addComponent(new Mass(0.1 + 0.1 ^^ 2));
  
  return entity;
}

Entity createStartupSound(World world)
{
  Entity startupSound = world.createEntity();
  startupSound.addComponent(new Sound("gasturbinestartup.ogg"));
  return startupSound;
}
