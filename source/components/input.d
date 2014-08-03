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
    string[SDL_Keycode] key;
    
    // TODO: mouse left/right/middle button codes are typed as anonymous enums in SDL2 and derelict
    string[Uint8] button; 
  }
  
  InputForAction inputForAction;
  
  ActionState[string] actionState;
  string text;
  
  this(InputForAction inputForAction)
  {
    this.inputForAction = inputForAction;
    
    foreach (string action; this.inputForAction.key.values)
      actionState[action] = ActionState.Inactive;
    foreach (string action; this.inputForAction.button.values)
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
  
  void updateActionStates()
  {
    foreach (SDL_Keycode key, string action; inputForAction.key)
    {
      if (actionState[action] == Input.ActionState.Released)
        actionState[action] = Input.ActionState.Inactive;
      if (actionState[action] == Input.ActionState.Pressed)
        actionState[action] = Input.ActionState.Held;
    }
    
    foreach (Uint8 button, string action; inputForAction.button)
    {
      if (actionState[action] == Input.ActionState.Released)
        actionState[action] = Input.ActionState.Inactive;
      if (actionState[action] == Input.ActionState.Pressed)
        actionState[action] = Input.ActionState.Held;
    }
  }
  
  static InputForAction playerInput;
  static InputForAction gameControls;
  static InputForAction textInput;
  
  static this()
  {
    playerInput.key[SDLK_UP] = "accelerate";
    playerInput.key[SDLK_DOWN] = "decelerate";
    playerInput.key[SDLK_LEFT] = "rotateLeft";
    playerInput.key[SDLK_RIGHT] = "rotateRight";
    playerInput.key[SDLK_SPACE] = "fire";
    
    gameControls.key[SDLK_PAGEUP] = "zoomIn";
    gameControls.key[SDLK_PAGEDOWN] = "zoomOut";
    gameControls.key[SDLK_ESCAPE] = "quit";
    gameControls.key[SDLK_INSERT] = "addEntity";
    gameControls.key[SDLK_DELETE] = "removeEntity";
    gameControls.key[SDLK_F1] = "toggleDebugInfo";
    gameControls.button[SDL_BUTTON_RIGHT] = "toggleInputWindow";
    
    textInput.key[SDLK_BACKSPACE] = "backspace";
  }
}
