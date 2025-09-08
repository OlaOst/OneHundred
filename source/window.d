module window;

import std;

import bindbc.opengl;
import bindbc.sdl;
import bindbc.loader;
import loader = bindbc.loader.sharedlib;


SDL_Window* getWindow(int screenWidth, int screenHeight)
{
  scope(failure) 
    loader.errors.each!(info => writeln(info.error.to!string, ": ", info.message.to!string));
      
  version (Windows)
  {        
    auto loadedSDLSupport = loadSDL("SDL3.dll");
    
    if (loadedSDLSupport != LoadMsg.success)
    {
      enforce(loadedSDLSupport != LoadMsg.noLibrary, "Failed to load SDL library");
      enforce(loadedSDLSupport != LoadMsg.badLibrary, "Error loading SDL library");
    }
    
    auto loadedSDLImage = loadSDLImage("SDL3_Image.dll");
    enforce(loadedSDLImage == LoadMsg.success, "Failed to load SDLImage library");
  }
  else
  {
    auto loadedSDLSupport = loadSDL();

    if (loadedSDLSupport != LoadMsg.success)
    {
      enforce(loadedSDLSupport != LoadMsg.noLibrary, "Failed to load SDL library");
      enforce(loadedSDLSupport != LoadMsg.badLibrary, "Error loading SDL library");
    }

    auto loadedSDLImage = loadSDLImage();    
    enforce(loadedSDLImage == LoadMsg.success, "Failed to load SDLImage library");
  }

  enforce(SDL_Init(SDL_INIT_VIDEO), "Failed to initialize SDL: " ~ SDL_GetError().to!string);
  //enforce(IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG) & (IMG_INIT_JPG | IMG_INIT_PNG),
          //"IMG_Init failed: " ~ IMG_GetError().to!string);

  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
  SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8);

  auto window = SDL_CreateWindow("OneHundred",
                                 screenWidth,
                                 screenHeight,
                                 SDL_WINDOW_OPENGL);

  enforce(window !is null, "Error creating window");

  auto context = SDL_GL_CreateContext(window);
  enforce(context !is null, "Error creating OpenGL context");

  SDL_GL_SetSwapInterval(1);

  auto loadedGLSupport = loadOpenGL();
  if (loadedGLSupport != GLSupport.gl41)
  {
    enforce(loadedGLSupport != GLSupport.noLibrary, "Failed to load OpenGL library");
    enforce(loadedGLSupport != GLSupport.badLibrary, "Error loading OpenGL library");
    enforce(loadedGLSupport != GLSupport.noContext, 
      "Did not get context after loading OpenGL library, forgot to create context first?");
  }

  // setup gl viewport and etc
  glViewport(0, 0, screenWidth, screenHeight);
  
  //glEnable(GL_DEPTH_TEST);
  glEnable(GL_BLEND);
  //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  
  glEnable(GL_STENCIL_TEST);
  
  glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD);
  glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ZERO);
  
  return window;
}
