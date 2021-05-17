module inputdefaults;

import bindbc.sdl;

import components.input;


static Input.InputForAction playerInput;
static Input.InputForAction playerEngine;
static Input.InputForAction playerGun;
static Input.InputForAction gameControls;
static Input.InputForAction textInput;

static this()
{
  playerInput.key[SDLK_UP] = "accelerate";
  playerInput.key[SDLK_DOWN] = "decelerate";
  playerInput.key[SDLK_LEFT] = "rotateCounterClockwise";
  playerInput.key[SDLK_RIGHT] = "rotateClockwise";
  playerInput.key[SDLK_SPACE] = "fire";

  playerEngine.key[SDLK_UP] = "accelerate";
  playerEngine.key[SDLK_DOWN] = "decelerate";
  playerEngine.key[SDLK_LEFT] = "rotateCounterClockwise";
  playerEngine.key[SDLK_RIGHT] = "rotateClockwise";
  
  playerGun.key[SDLK_SPACE] = "fire";
  
  gameControls.key[SDLK_PAGEUP] = "zoomIn";
  gameControls.key[SDLK_PAGEDOWN] = "zoomOut";
  gameControls.key[SDLK_ESCAPE] = "quit";
  gameControls.event[SDL_QUIT] = "quit";
  gameControls.key[SDLK_INSERT] = "addEntity";
  gameControls.key[SDLK_DELETE] = "removeEntity";
  gameControls.scancode[SDL_SCANCODE_TAB] = "addEntity";
  gameControls.scancode[SDL_SCANCODE_MINUS] = "removeEntity";

  gameControls.key[SDLK_F4] = "attemptNetworkConnection";
  gameControls.key[SDLK_F1] = "toggleDebugInfo";
  gameControls.key[SDLK_F2] = "toggleDebugEntities";
  gameControls.button[SDL_BUTTON_LEFT] = "focusInputWindow";
  gameControls.button[SDL_BUTTON_RIGHT] = "toggleInputWindow";

  textInput.key[SDLK_BACKSPACE] = "backspace";
  textInput.key[SDLK_RETURN] = "newline";
}
