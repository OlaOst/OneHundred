import std.exception;
import std.conv;
import std.math;
import std.range;
import std.stdio;

import artemisd.all;
import derelict.opengl3.gl3;
import derelict.sdl2.sdl;

import component.position;
import component.velocity;
import component.drawable;
import system.movement;
import system.renderer;


bool keepRunning = true;

void main()
{
  auto window = getWindow();
  auto renderer = new Renderer();
  
  auto world = new World();
  world.setSystem(new Movement(world));
  world.setSystem(renderer);
  world.initialize();
  
  auto elements = 10;
  foreach (float index; iota(0, elements))
  {
    debug writeln("adding element with index " ~ index.to!string);
    
    auto angle = (index/elements) * PI * 2.0;
    
    Entity entity = world.createEntity();
    entity.addComponent(new Position(cos(angle) * 0.1, sin(angle) * 0.1));
    entity.addComponent(new Velocity(sin(angle) * 0.1, cos(angle) * 0.1));
    entity.addComponent(new Drawable(0.1));
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


SDL_Window* getWindow()
{
  DerelictSDL2.load();
  DerelictGL3.load();
  
  enforce(SDL_Init(SDL_INIT_VIDEO) == 0, "Failed to initialize SDL: " ~ SDL_GetError().to!string);
  
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
  
  int screenWidth = 800;
  int screenHeight = 600;
  
  auto window = SDL_CreateWindow("greenfield", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, screenWidth, screenHeight, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
  enforce(window !is null, "Error creating window");
  
  auto context = SDL_GL_CreateContext(window);
  enforce(context !is null, "Error creating OpenGL context");
  
  SDL_GL_SetSwapInterval(1);
  
  // setup gl viewport and etc
  glViewport(0, 0, screenWidth, screenHeight);
  
  DerelictGL3.reload();
  
  return window;
}
