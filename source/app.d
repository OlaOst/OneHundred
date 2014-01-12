import std.algorithm;
import std.exception;
import std.conv;
import std.math;
import std.random;
import std.range;
import std.stdio;

import artemisd.all;
import derelict.sdl2.sdl;
import gl3n.linalg;

import component.drawable;
import component.input;
import component.mass;
import component.position;
import component.relations.collider;
import component.relations.gravity;
import component.size;
import component.velocity;

import system.collisionhandler;
import system.movement;
import system.renderer;
import system.physics;

import input;
import window;


void main()
{
  auto window = getWindow(1024, 768);
  auto renderer = new Renderer();
  
  auto world = new World();
  //world.setSystem(new Movement(world));
  world.setSystem(new Physics(world));
  world.setSystem(new CollisionHandler(world));
  world.setSystem(renderer);
  world.initialize();
  
  auto playerManager = new PlayerManager();
  
  Entity playerEntity = world.createEntity();
  playerEntity.addComponent(new Position(vec2(0.0, 0.0), 0.0));
  playerEntity.addComponent(new Velocity(vec2(0.0, 0.0), 0.0));
  playerEntity.addComponent(new Size(0.3));
  playerEntity.addComponent(new Mass(0.3 ^^ 2));
  playerEntity.addComponent(new Drawable(0.3, 3, vec3(0.0, 1.0, 0.0)));
  playerEntity.addComponent(new Input());
  playerManager.setPlayer(playerEntity, "player");
  
  playerEntity.addToWorld();
  
  Entity[] entities;
  
  auto elements = 100;
  foreach (float index; iota(0, elements))
  {
    auto angle = (index/elements) * PI * 2.0;
    auto size = uniform(0.01, 0.1);
    
    Entity entity = world.createEntity();
    
    entity.addComponent(new Position(vec2(cos(angle*5) * (0.3+angle.sqrt), 
                                          sin(angle*5) * (0.3+angle.sqrt)), 
                                     0.0));
    entity.addComponent(new Velocity(vec2(sin(angle) * 0.5, 
                                          cos(angle) * 0.5), 
                                     uniform(-PI, PI)));
    entity.addComponent(new Size(size));
    entity.addComponent(new Mass(0.1 + size ^^ 2));
    entity.addComponent(new Drawable(size, uniform(3, 12), uniformDistribution!float(3).vec3));
    entity.addComponent(new Input());
    
    entities ~= entity;
  }
  
  playerEntity.addComponent(new Gravity(entities));
  playerEntity.addComponent(new Collider(entities));
  
  foreach (entity; entities)
  {
    entity.addComponent(new Gravity(entities.filter!(checkEntity => checkEntity != entity).array ~ playerEntity));
    entity.addComponent(new Collider(entities.filter!(checkEntity => checkEntity != entity).array ~ playerEntity));
    entity.addToWorld();
  }

  scope (exit)
  {
    renderer.close();
  }
  
  while (input.keepRunning)
  {
    world.setDelta(1.0/60.0);
    world.process();
  
    input.handleEvents();
    
    if (input.zoomIn)
      renderer.zoom += renderer.zoom * 1.0/60.0;
    if (input.zoomOut)
      renderer.zoom -= renderer.zoom * 1.0/60.0;
    
    assert(playerEntity.getComponent!Input);
    
    playerEntity.getComponent!Input.accelerate = input.accelerate;
    playerEntity.getComponent!Input.decelerate = input.decelerate;
    playerEntity.getComponent!Input.rotateLeft = input.rotateLeft;
    playerEntity.getComponent!Input.rotateRight = input.rotateRight;
    
    renderer.draw();

    SDL_GL_SwapWindow(window);
  }
}
