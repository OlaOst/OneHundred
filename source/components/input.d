module components.input;

import std.conv;

import bindbc.sdl;

import inputdefaults;


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
    string[SDL_EventType] event;
    string[SDL_Scancode] scancode;
    // TODO: mouse left/right/middle button codes are typed as anonymous enums in SDL2 and derelict
    string[Uint8] button;
  }

  InputForAction inputForAction;
  ActionState[string] actionState;
  string text;

  this(string inputType)
  {
    if (inputType == "playerInput")
      inputForAction = inputdefaults.playerInput;
    else if (inputType == "playerEngine")
      inputForAction = inputdefaults.playerEngine;
    else if (inputType == "playerGun")
      inputForAction = inputdefaults.playerGun;
    else if (inputType == "gameControls")
      inputForAction = inputdefaults.gameControls;
    else if (inputType == "textInput")
      inputForAction = textInput;
    else if (inputType == "npcGun" || inputType == "npcEngine")
      inputForAction = InputForAction.init;
    else
      assert(false, "Found unhandled input type: " ~ inputType);

    foreach (string action; inputForAction.key.values)
      actionState[action] = ActionState.Inactive;
    foreach (string action; inputForAction.button.values)
      actionState[action] = ActionState.Inactive;
  }

  ActionState getActionState(string action)
  {
    return (action in actionState) ? actionState[action] : ActionState.Unknown;
  }

  void setAction(string action)
  {
    actionState[action] = ActionState.Pressed;
  }
  
  void resetAction(string action)
  {
    actionState[action] = ActionState.Released;
  }

  bool isActionSet(string action)
  {
    return getActionState(action) == ActionState.Pressed ||
           getActionState(action) == ActionState.Held;
  }

  bool isActionToggled(string action)
  {
    return getActionState(action) == Input.ActionState.Pressed;
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
}
