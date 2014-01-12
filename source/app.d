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

import entityfactory;
import input;
import window;


void main()
{
  auto window = getWindow(1024, 768);
  auto renderer = new Renderer();
  
  auto world = new World();
  //world.setSystem(new Movement(world));
  auto physics = new Physics(world);
  world.setSystem(physics);
  world.setSystem(new CollisionHandler(world));
  world.setSystem(renderer);
  world.initialize();
  
  auto playerEntity = createPlayer(world);
  
  playerEntity.addToWorld();
  
  Entity[] entities;
  
  entities ~= playerEntity;
  
  auto elements = 30;
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
    entity.addComponent(new Gravity(entities.filter!(checkEntity => checkEntity != entity).array));
    entity.addComponent(new Collider(entities.filter!(checkEntity => checkEntity != entity).array));
    entity.addToWorld();
  }

  scope (exit)
  {
    renderer.close();
  }
  
  StopWatch timer;
  timer.start();
  
  double time = 0.0;
  const double physicsTimeStep = 1.0 / 60.0;
  double currentTime = timer.peek().usecs * (1.0 / 1_000_000);
  double accumulator = 0.0;
  
  while (input.keepRunning)
  {
    double newTime = timer.peek().usecs * (1.0 / 1_000_000);
    double frameTime = newTime - currentTime;
    currentTime = newTime;
    
    accumulator += frameTime;
    
    while (accumulator >= physicsTimeStep)
    {
      //debug writeln("physics.update(", time, ", ", physicsTimeStep, ") accumulator is ", accumulator);
      
      physics.integrate(time, physicsTimeStep);
      
      accumulator -= physicsTimeStep;
      time += physicsTimeStep;
    }
    
    physics.interpolateStates(accumulator / physicsTimeStep);
    
    physics.resetStates();
    
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
