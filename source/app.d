import std.algorithm;
import std.datetime;
import std.exception;
import std.math;
import std.random;
import std.range;
import std.stdio;

import artemisd.all;
import derelict.sdl2.sdl;
import gl3n.linalg;

import component.input;
import component.relations.collider;
import component.relations.gravity;

import system.collisionhandler;
import system.inputhandler;
import system.movement;
import system.renderer;
import system.physics;

import entityfactory;
import timer;
import window;


void main()
{
  auto window = getWindow(1024, 768);
  auto renderer = new Renderer();
  auto timer = new Timer();
  auto world = new World();
  auto physics = new Physics(world);
  auto inputHandler = new InputHandler();
  auto collisionHandler = new CollisionHandler();
  world.setSystem(physics);
  world.setSystem(inputHandler);
  world.setSystem(collisionHandler);
  world.setSystem(renderer);
  world.initialize();
  
  auto gameController = createGameController(world);
  gameController.addToWorld();
  
  auto playerEntity = createPlayer(world);
  playerEntity.addToWorld();
  
  Entity[] entities;
  entities ~= playerEntity;
  
  auto elements = 200;
  foreach (double index; iota(0, elements))
  {
    auto angle = (index/elements) * PI * 2.0;
    auto size = uniform(0.01, 0.1);
    auto entity = createEntity(world, vec2(cos(angle * 5) * (0.3 + angle.sqrt),
                                           sin(angle * 5) * (0.3 + angle.sqrt)),
                                      vec2(sin(angle) * 0.5, cos(angle) * 0.5),
                                      size);
    entities ~= entity;
  }
  
  foreach (entity; entities)
  {
    auto otherEntities = entities.filter!(checkEntity => checkEntity != entity).array;
    entity.addComponent(new Collider(otherEntities));
    entity.addToWorld();
  }

  scope (exit)
  {
    renderer.close();
  }
  
  bool keepRunning = true;
  timer.start();
  while (keepRunning)
  {
    timer.incrementAccumulator();
    physics.update(timer);
    collisionHandler.update();
    
    world.setDelta(1.0/60.0);
    world.process();
  
    inputHandler.update();
    auto gameActions = gameController.getComponent!Input.isActive;
    if ("zoomIn" in gameActions && gameActions["zoomIn"])
      renderer.zoom += renderer.zoom * 1.0/60.0;
    if ("zoomOut" in gameActions && gameActions["zoomOut"])
      renderer.zoom -= renderer.zoom * 1.0/60.0;
    if ("quit" in gameActions && gameActions["quit"])
      keepRunning = false;
      
    renderer.draw();
    SDL_GL_SwapWindow(window);
  }
}
