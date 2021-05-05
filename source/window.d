module window;

import std;

import derelict.opengl;
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;


SDL_Window* getWindow(int screenWidth, int screenHeight)
{
  version (Windows)
  {
    scope(failure) 
      loader.errors.each!(info => writeln(info.error.to!string, ": ", info.message.to!string));
        
    auto loadedSDLSupport = loadSDL("SDL2.dll");
    
    if (loadedSDLSupport != sdlSupport)
    {
      enforce(loadedSDLSupport != SDLSupport.noLibrary, "Failed to load SDL library");
      enforce(loadedSDLSupport != SDLSupport.badLibrary, "Error loading SDL library");
    }
    
    auto loadedSDLImage = loadSDLImage("SDL2_Image.dll");
    enforce(loadedSDLImage == sdlImageSupport, "Failed to load SDLImage library");
  }
  
  DerelictGL3.load();

  enforce(SDL_Init(SDL_INIT_VIDEO) == 0, "Failed to initialize SDL: " ~ SDL_GetError().to!string);
  enforce(IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG) & (IMG_INIT_JPG | IMG_INIT_PNG),
          "IMG_Init failed: " ~ IMG_GetError().to!string);

  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
  SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8);

  auto window = SDL_CreateWindow("OneHundred",
                                 SDL_WINDOWPOS_CENTERED,
                                 SDL_WINDOWPOS_CENTERED,
                                 screenWidth,
                                 screenHeight,
                                 SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);

  enforce(window !is null, "Error creating window");

  auto context = SDL_GL_CreateContext(window);
  enforce(context !is null, "Error creating OpenGL context");

  SDL_GL_SetSwapInterval(1);

  // setup gl viewport and etc
  glViewport(0, 0, screenWidth, screenHeight);
  
  //glEnable(GL_DEPTH_TEST);
  glEnable(GL_BLEND);
  //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  
  glEnable(GL_STENCIL_TEST);
  
  DerelictGL3.reload();
  
  glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD);
  glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ZERO);
  
  return window;
}
