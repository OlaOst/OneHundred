import std.exception;
import std.conv;
import std.math;
import std.range;
import std.stdio;

import artemisd.all;
import derelict.sdl2.sdl;

import component.position;
import component.velocity;
import component.mass;
import component.drawable;
import system.movement;
import system.renderer;
import system.physics;
import window;

bool keepRunning = true;

void main()
{
  auto window = getWindow(1024, 768);
  auto renderer = new Renderer();
  
  auto world = new World();
  world.setSystem(new Movement(world));
  world.setSystem(new Physics(world));
  world.setSystem(renderer);
  world.initialize();
  
  auto elements = 1500;
  foreach (float index; iota(0, elements))
  {
    debug writeln("adding element with index " ~ index.to!string);
    
    auto angle = (index/elements) * PI * 2.0;
    
    Entity entity = world.createEntity();
    entity.addComponent(new Position(cos(angle) * 0.5, sin(angle) * 0.5));
    entity.addComponent(new Velocity(sin(angle) * 0.2, cos(angle) * 0.2));
    
    auto size = 0.1 + sin(angle*5.0) * 0.1;
    
    entity.addComponent(new Mass(0.1 + size ^^ 2));
    
    entity.addComponent(new Drawable(size));
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
  
    handleEvents();
    
    renderer.draw();

    SDL_GL_SwapWindow(window);
  }
}


void handleEvents()
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
          
          default:
            break;
        }
        break;
        
      default:
        break;
    }
  }
}
