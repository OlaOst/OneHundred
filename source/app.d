import std.exception;
import std.conv;
import std.stdio;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;


bool keepRunning = true;

void main()
{
  auto window = getWindow();
  
  while (keepRunning)
  {
    handleEvents();

    swapWindow();
  }
}


void swapWindow()
{
  SDL_GL_SwapWindow(window);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
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
  glClearColor(0.0, 0.0, 0.5, 1.0);
  
  glViewport(0, 0, screenWidth, screenHeight);
  
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  DerelictGL3.reload();
  
  return window;
}
