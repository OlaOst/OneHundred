module component.input;

import derelict.sdl2.sdl;


class Input
{
  enum ActionState
  {
    Unknown,
    Inactive,
    Pressed,
    Held,
    Released,
  }

  SDL_Keycode[string] keyForAction;
  ActionState[string] actionState;
  
  this(SDL_Keycode[string] keyForAction)
  {
    this.keyForAction = keyForAction;
    
    foreach (string action; this.keyForAction.keys)
      actionState[action] = ActionState.Inactive;
  }
  
  ActionState getActionState(string action)
  {
    return (action in actionState) ? actionState[action] : ActionState.Unknown;
  }
  
  void setAction(string action, ref bool value)
  {
    value = getActionState(action) == ActionState.Pressed || 
            getActionState(action) == ActionState.Held;
  }
  
  void toggleAction(string action, ref bool value)
  {
    value = getActionState(action) == Input.ActionState.Pressed;
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
    playerInput["fire"] = SDLK_SPACE;
    
    gameControls["zoomIn"] = SDLK_PAGEUP;
    gameControls["zoomOut"] = SDLK_PAGEDOWN;
    gameControls["quit"] = SDLK_ESCAPE;
    gameControls["addEntity"] = SDLK_INSERT;
    gameControls["removeEntity"] = SDLK_DELETE;
    gameControls["toggleDebugInfo"] = SDLK_d;
  }
}
