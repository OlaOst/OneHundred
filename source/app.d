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

import window;


void main()
{
  // TODO: put these in separate input module
  bool keepRunning = true;
  bool zoomIn = false;
  bool zoomOut = false;
  
  auto window = getWindow(1024, 768);
  auto renderer = new Renderer();
  
  auto world = new World();
  world.setSystem(new Movement(world));
  world.setSystem(new Physics(world));
  world.setSystem(new CollisionHandler(world));
  world.setSystem(renderer);
  world.initialize();
  
  Entity[] entities;
  
  auto elements = 150;
  foreach (float index; iota(0, elements))
  {
    auto angle = (index/elements) * PI * 2.0;
    auto size = uniform(0.01, 0.025);
    
    Entity entity = world.createEntity();
    
    //entity.addComponent(new Position(cos(angle) * 0.5, sin(angle) * 0.5, 0.0));
    entity.addComponent(new Position(uniform(-1.0, 1.0), uniform(-1.0, 1.0), uniform(-PI, PI)));
    entity.addComponent(new Velocity(sin(angle) * 0.5, cos(angle) * 0.5, uniform(-PI, PI)));
    entity.addComponent(new Size(size));
    entity.addComponent(new Mass(0.1 + size ^^ 2));
    entity.addComponent(new Drawable(size, vec3(1.0, sin(angle*5.0)*0.5+0.5, 0.0)));
    
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
  
  while (keepRunning)
  {
    world.setDelta(1.0/60.0);
    world.process();
  
    handleEvents(keepRunning, renderer, zoomIn, zoomOut);
    
    if (zoomIn)
      renderer.zoom += renderer.zoom * 1.0/60.0;
    if (zoomOut)
      renderer.zoom -= renderer.zoom * 1.0/60.0;
    
    renderer.draw();

    SDL_GL_SwapWindow(window);
  }
}


void handleEvents(ref bool keepRunning, ref Renderer renderer, ref bool zoomIn, ref bool zoomOut)
{
  SDL_Event event;

  while (SDL_PollEvent(&event))
  {
    switch (event.type)
    {
      case SDL_QUIT:
        keepRunning = false;
        break;
        
      case SDL_KEYUP:
        switch (event.key.keysym.sym)
        {
          case SDLK_ESCAPE:
            keepRunning = false;
            break;

          case SDLK_PAGEDOWN:
            //renderer.zoom -= renderer.zoom * 1.0/60.0;
            zoomOut = false;
            break;
          
          case SDLK_PAGEUP:
            //renderer.zoom += renderer.zoom * 1.0/60.0;
            zoomIn = false;
            break;
            
          default:
            break;
        }
        break;
        
      case SDL_KEYDOWN:
        switch (event.key.keysym.sym)
        {
          case SDLK_PAGEDOWN:
            //renderer.zoom -= renderer.zoom * 1.0/60.0;
            zoomOut = true;
            break;
          
          case SDLK_PAGEUP:
            //renderer.zoom += renderer.zoom * 1.0/60.0;
            zoomIn = true;
            break;
          
          default:
            break;
        }
        break;
        
      default:
        break;
    }
  }
}
