module components.input;

import std.conv;

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

  struct InputForAction
  {
    SDL_Keycode[string] key;
    
    // TODO: mouse left/right/middle button codes are typed as anonymous enums in SDL2 and derelict
    Uint8[string] button; 
  }
  
  InputForAction inputForAction;
  
  ActionState[string] actionState;
  string text;
  
  this(InputForAction inputForAction)
  {
    this.inputForAction = inputForAction;
    
    foreach (string action; this.inputForAction.key.keys)
      actionState[action] = ActionState.Inactive;
    foreach (string action; this.inputForAction.button.keys)
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
  
  static InputForAction playerInput;
  static InputForAction gameControls;
  static InputForAction textInput;
  
  static this()
  {
    playerInput.key["accelerate"] = SDLK_UP;
    playerInput.key["decelerate"] = SDLK_DOWN;
    playerInput.key["rotateLeft"] = SDLK_LEFT;
    playerInput.key["rotateRight"] = SDLK_RIGHT;
    playerInput.key["fire"] = SDLK_SPACE;
    
    gameControls.key["zoomIn"] = SDLK_PAGEUP;
    gameControls.key["zoomOut"] = SDLK_PAGEDOWN;
    gameControls.key["quit"] = SDLK_ESCAPE;
    gameControls.key["addEntity"] = SDLK_INSERT;
    gameControls.key["removeEntity"] = SDLK_DELETE;
    gameControls.key["toggleDebugInfo"] = SDLK_F1;
    gameControls.button["toggleInputWindow"] = SDL_BUTTON_RIGHT;
    
    textInput.key["backspace"] = SDLK_BACKSPACE;
  }
}
