module component.input;

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

  SDL_Keycode[string] keyForAction;
  ActionState[string] actionState;
  string text;
  
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
  static SDL_Keycode[string] textInput;
  
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
    gameControls["toggleDebugInfo"] = SDLK_F1;
    
    //for (char letter = 'a'; letter <= 'z'; letter++)
      //textInput["" ~ letter] = letter;
    //for (char letter = '0'; letter <= '9'; letter++)
      //textInput[letter.to!string] = letter;
    textInput["backspace"] = SDLK_BACKSPACE;
    //textInput[" "] = SDLK_SPACE;
    //textInput["!"] = SDLK_EXCLAIM;
    //textInput["\""] = SDLK_QUOTEDBL;
    
    
    /+
    SDLK_UNKNOWN = 0,
    SDLK_RETURN = '\r',
    SDLK_ESCAPE = '\033',
    SDLK_TAB = '\t',
    SDLK_EXCLAIM = '!',
    SDLK_QUOTEDBL = '"',
    SDLK_HASH = '#',
    SDLK_PERCENT = '%',
    SDLK_DOLLAR = '$',
    SDLK_AMPERSAND = '&',
    SDLK_QUOTE = '\'',
    SDLK_LEFTPAREN = '(',
    SDLK_RIGHTPAREN = ')',
    SDLK_ASTERISK = '*',
    SDLK_PLUS = '+',
    SDLK_COMMA = ',',
    SDLK_MINUS = '-',
    SDLK_PERIOD = '.',
    SDLK_SLASH = '/',
    SDLK_COLON = ':',
    SDLK_SEMICOLON = ';',
    SDLK_LESS = '<',
    SDLK_EQUALS = '=',
    SDLK_GREATER = '>',
    SDLK_QUESTION = '?',
    SDLK_AT = '@',

    SDLK_LEFTBRACKET = '[',
    SDLK_BACKSLASH = '\\',
    SDLK_RIGHTBRACKET = ']',
    SDLK_CARET = '^',
    SDLK_UNDERSCORE = '_',
    SDLK_BACKQUOTE = '`',
    +/
  }
}
