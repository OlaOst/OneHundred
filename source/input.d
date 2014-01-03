module input;

import derelict.sdl2.sdl;


bool keepRunning = true;
bool zoomIn = false;
bool zoomOut = false;


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
