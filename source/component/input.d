module component.input;

import derelict.sdl2.sdl;


class Input
{
  SDL_Keycode[string] keyForAction;
  bool[string] isActive;
  
  this(SDL_Keycode[string] keyForAction)
  {
    this.keyForAction = keyForAction;
  }
  
  // TODO: would be neat to make these static initalized
  // but DMD 2.064 cannot static initialize AAs
  static SDL_Keycode[string] playerInput;/* = ["accelerate" : SDLK_UP,
                                            "decelerate" : SDLK_DOWN,
                                            "rotateLeft" : SDLK_LEFT,
                                            "rotateRight" : SDLK_RIGHT];*/

  static SDL_Keycode[string] gameControls;
  
  static this()
  {
    playerInput["accelerate"] = SDLK_UP;
    playerInput["decelerate"] = SDLK_DOWN;
    playerInput["rotateLeft"] = SDLK_LEFT;
    playerInput["rotateRight"] = SDLK_RIGHT;
    
    gameControls["zoomIn"] = SDLK_PAGEUP;
    gameControls["zoomOut"] = SDLK_PAGEDOWN;
    gameControls["quit"] = SDLK_ESCAPE;
  }
}
