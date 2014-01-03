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
            zoomOut = false;
            break;
          
          case SDLK_PAGEUP:
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
            zoomOut = true;
            break;
          
          case SDLK_PAGEUP:
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
