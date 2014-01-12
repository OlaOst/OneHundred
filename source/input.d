module input;

import derelict.sdl2.sdl;


bool keepRunning = true;
bool zoomIn = false;
bool zoomOut = false;

bool accelerate = false;
bool decelerate = false;
bool rotateLeft = false;
bool rotateRight = false;

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
            
          case SDLK_UP:
            accelerate = false;
            break;
          
          case SDLK_DOWN:
            decelerate = false;
            break;
            
          case SDLK_LEFT:
            rotateLeft = false;
            break;
          
          case SDLK_RIGHT:
            rotateRight = false;
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

          case SDLK_UP:
            accelerate = true;
            break;
          
          case SDLK_DOWN:
            decelerate = true;
            break;
            
          case SDLK_LEFT:
            rotateLeft = true;
            break;
          
          case SDLK_RIGHT:
            rotateRight = true;
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
